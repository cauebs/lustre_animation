import gleam/dict.{type Dict}
import gleam/result
import lustre/effect.{type Effect}

/// Represents an animated value of a certain type. It can be created with [`create`](#create) and
/// then added to an Animator along with an identifier, and later evaluated at a certain time.
pub opaque type Animation(a) {
  OneShot(fn(Float) -> a, duration: Float)
  Sequence(Animation(a), next: Animation(a))
  Looping(Animation(a))
}

/// Create an animation from an interpolation function that takes values from `0.0` when it starts
/// to `1.0` when it ends, after the duration given in milliseconds.
///
/// The [`animation/interpolation`](./animation/interpolation.html) module provides some simple
/// functions to help you get started, such as a lerp (linear interpolation).
///
/// See the [`delay`](#delay), [`repeat`](#repeat), [`repeat_forever`](#repeat_forever),
/// [`reverse`](#reverse) and [`chain`](#chain) functions for ways to compose animations into more
/// complex ones without requiring too complicated interpolation functions.
pub fn create(with fun: fn(Float) -> a, for duration_ms: Float) -> Animation(a) {
  OneShot(fun, duration: duration_ms)
}

/// Delay the start of an animation by a duration given in milliseconds.
pub fn delay(animation: Animation(a), delay_ms: Float) -> Animation(a) {
  let initial_value = initial_value(animation)
  Sequence(
    OneShot(fn(_t) { initial_value }, duration: delay_ms),
    next: animation,
  )
}

/// Repeat an animation a given amount of times.
pub fn repeat(animation: Animation(a), times: Int) -> Animation(a) {
  case times {
    1 -> animation
    _ -> Sequence(animation, next: repeat(animation, times - 1))
  }
}

/// Repeat an animation forever.
pub fn repeat_forever(animation: Animation(a)) -> Animation(a) {
  Looping(animation)
}

/// Reverse an animation.
pub fn reverse(animation: Animation(a)) -> Animation(a) {
  case animation {
    OneShot(fun, duration:) ->
      OneShot(fn(t) { fun(1.0 -. t) }, duration: duration)
    Sequence(inner, next:) -> Sequence(reverse(next), reverse(inner))
    Looping(animation) -> Looping(reverse(animation))
  }
}

/// Chain two animations so that when one ends the other one starts.
pub fn chain(animation: Animation(a), next: Animation(a)) -> Animation(a) {
  Sequence(animation, next:)
}

fn initial_value(animation: Animation(a)) -> a {
  case animation {
    OneShot(fun, _) -> fun(0.0)
    Sequence(first, _) -> initial_value(first)
    Looping(animation) -> initial_value(animation)
  }
}

fn final_value(animation: Animation(a)) -> a {
  case animation {
    OneShot(fun, _) -> fun(1.0)
    Sequence(_, next:) -> final_value(next)
    Looping(animation) -> final_value(animation)
  }
}

/// A collection that holds animations of a certain type and their current states.
pub opaque type Animator(id, a) {
  Animator(t: Float, animations: Dict(id, AnimationState(a)))
}

/// Create an empty Animator.
pub fn empty() -> Animator(id, a) {
  Animator(0.0, dict.new())
}

/// Add an animation to the Animator. The animation must be given an identifier which can later be
/// used to obtain its current value or cancel it.
pub fn add(
  animator: Animator(id, a),
  animation_id: id,
  animation: Animation(a),
) -> Animator(id, a) {
  Animator(
    ..animator,
    animations: animator.animations
      |> dict.insert(animation_id, NotStarted(animation)),
  )
}

/// Add many animations to the Animator. Has the same effect as calling [`add`](#add) several times.
pub fn add_many(
  animator: Animator(id, a),
  new_animations: List(#(id, Animation(a))),
) -> Animator(id, a) {
  let animations =
    new_animations
    |> dict.from_list()
    |> dict.map_values(fn(_id, animation) { NotStarted(animation) })
    |> dict.merge(animator.animations)

  Animator(..animator, animations:)
}

/// Remove the animation specified by the identifier from the Animator.
pub fn cancel(animator: Animator(id, a), animation_id: id) -> Animator(id, a) {
  Animator(
    ..animator,
    animations: animator.animations
      |> dict.delete(animation_id),
  )
}

/// List the identifiers of the animations contained in the Animator.
pub fn ids(animator: Animator(id, a)) -> List(id) {
  dict.keys(animator.animations)
}

/// Represents the end time of the previous frame's rendering.
pub opaque type Timestamp {
  Timestamp(Float)
}

fn timestamp_to_millis(timestamp: Timestamp) -> Float {
  let Timestamp(ms) = timestamp
  ms
}

@internal
pub fn timestamp_from_millis(ms: Float) -> Timestamp {
  Timestamp(ms)
}

/// Update all animations with the timestamp obtained from a message produced by `effect`.
pub fn tick(animator: Animator(id, a), timestamp: Timestamp) -> Animator(id, a) {
  let elapsed_ms = timestamp_to_millis(timestamp)

  let animations =
    animator.animations
    |> dict.filter(fn(_id, state) {
      case state {
        Done(_) -> False
        _ -> True
      }
    })
    |> dict.map_values(fn(_id, state) { tick_animation(state, elapsed_ms) })

  Animator(t: elapsed_ms, animations:)
}

type AnimationState(a) {
  NotStarted(Animation(a))
  Running(Animation(a), start: Float)
  // The state Done will guarantee the value for t=1.0 is returned,
  // before the Animation is removed from the list.
  Done(Animation(a))
}

fn tick_animation(
  state: AnimationState(a),
  elapsed_ms: Float,
) -> AnimationState(a) {
  case state {
    NotStarted(animation) -> Running(animation, start: elapsed_ms)

    Running(OneShot(_, duration:) as animation, start:) ->
      case elapsed_ms >=. start +. duration {
        True -> Done(animation)
        False -> Running(animation, start: start)
      }

    Running(Sequence(inner, next:), start:) ->
      case Running(inner, start:) |> tick_animation(elapsed_ms) {
        NotStarted(_) -> panic
        Running(animation, start:) ->
          Running(Sequence(animation, next:), start:)
        Done(_) -> Running(next, start: elapsed_ms)
      }

    Running(Looping(inner), start:) ->
      case Running(inner, start:) |> tick_animation(elapsed_ms) {
        NotStarted(_) -> panic
        Running(..) -> state
        Done(_) -> Running(Looping(inner), start: elapsed_ms)
      }

    Done(animation) -> Done(animation)
  }
}

/// If the animation specified by `which` is not found, returns `Error(Nil)`.
/// Otherwise, the current value for the animation is returned.
pub fn value(animator: Animator(id, a), which: id) -> Result(a, Nil) {
  animator.animations
  |> dict.get(which)
  |> result.map(evaluate(_, animator.t))
}

/// Evaluates all animations contained in the Animator and returns their values.
pub fn values(animator: Animator(id, a)) -> Dict(id, a) {
  animator.animations
  |> dict.map_values(fn(_id, animation) { evaluate(animation, animator.t) })
}

fn evaluate(animation: AnimationState(a), elapsed_time: Float) -> a {
  case animation {
    NotStarted(animation) -> initial_value(animation)

    Running(animation, start:) -> {
      case animation {
        OneShot(fun, duration:) -> fun({ elapsed_time -. start } /. duration)
        Sequence(inner, _) | Looping(inner) ->
          evaluate(Running(inner, start:), elapsed_time)
      }
    }

    Done(animation) -> {
      final_value(animation)
    }
  }
}

/// Returns `effect.none()` if none of the animations is running.
/// Otherwise returns an opaque `Effect` that will cause `msg(timestamp)` to
/// be dispatched on a JavaScript `requestAnimationFrame`
pub fn effect(
  animator: Animator(id, a),
  msg: fn(Timestamp) -> msg,
) -> Effect(msg) {
  case dict.is_empty(animator.animations) {
    True -> effect.none()
    False ->
      effect.from(fn(dispatch) {
        js_request_animation_frame(fn(timestamp: Float) {
          dispatch(msg(Timestamp(timestamp)))
        })
        Nil
      })
  }
}

type RequestedFrame

@external(javascript, "../ffi.mjs", "request_animation_frame")
fn js_request_animation_frame(f: fn(Float) -> msg) -> RequestedFrame
