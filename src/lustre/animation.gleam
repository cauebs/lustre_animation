import lustre/cmd.{Cmd}
import gleam/list.{filter, find, map}

pub opaque type Animations {
  Animations(t: Float, List(Animation))
}

pub opaque type Animation {
  Animation(name: String, range: #(Float, Float), state: AnimationState)
}

//   InParallel(Animations)
//   InSequence(Animations)
//   Repeat(Animation)
//   Cancelled(Animation)

// The State Done will guarantee the `stop` value is returned, before the Animation is removed from the list
pub opaque type AnimationState {
  NotStarted(seconds: Float)
  Running(seconds: Float, since: Float)
  Done
}

pub fn new() {
  Animations(0.0, [])
}

pub fn add(animations: Animations, name, start, stop, seconds) -> Animations {
  use list <- change_list(animations)
  [Animation(name, #(start, stop), NotStarted(seconds)), ..list]
}

pub fn remove(animations: Animations, name) -> Animations {
  use list <- change_list(animations)
  filter(list, does_not_have_name(_, name))
  // Would not filter, but replace w/ Cancelled and filtered in the next call, see comments at bottom of this file
}

fn change_list(
  animations: Animations,
  f: fn(List(Animation)) -> List(Animation),
) -> Animations {
  let assert Animations(t, list) = animations
  Animations(t, f(list))
}

fn does_not_have_name(animation: Animation, name: String) {
  let assert Animation(n, _, _) = animation
  n != name
}

pub fn tick(animations: Animations, time_offset) -> Animations {
  let assert Animations(_, list) = animations
  let new_list =
    list
    |> filter(not_done)
    |> map(tick_animation(_, time_offset))
  Animations(time_offset, new_list)
}

fn not_done(animation: Animation) -> Bool {
  case animation {
    Animation(_, _, Done) -> False
    _ -> True
  }
}

fn tick_animation(animation: Animation, time: Float) -> Animation {
  let assert Animation(name, range, state) = animation
  let new_state = case state {
    NotStarted(seconds) -> Running(seconds, since: time)
    Running(seconds, since) ->
      case time -. since >=. seconds *. 1000.0 {
        True -> Done
        False -> state
      }
    Done -> Done
  }
  Animation(name, range, new_state)
}

pub fn cmd(animations: Animations, msg: fn(Float) -> m) -> Cmd(m) {
  case animations {
    Animations(_, []) -> cmd.none()
    _ -> next_frame(msg)
  }
}

pub fn value(animations: Animations, which: String, default: Float) -> Float {
  let assert Animations(t, list) = animations
  case find(list, has_name(_, which)) {
    Ok(animation) -> evaluate(animation, t)
    Error(Nil) -> default
  }
}

fn has_name(animation: Animation, name: String) {
  let assert Animation(n, _, _) = animation
  n == name
}

fn evaluate(animation: Animation, time: Float) -> Float {
  let assert Animation(_, #(start, stop), state) = animation
  case state {
    NotStarted(_) -> start
    Running(seconds, since) -> {
      let dt = time -. since
      let delta = dt /. { seconds *. 1000.0 }
      start +. { stop -. start } *. delta
    }
    Done -> stop
  }
}

fn next_frame(msg: fn(Float) -> m) -> Cmd(m) {
  cmd.from(fn(dispatch) {
    request_animation_frame(fn(time_offset: Float) {
      dispatch(msg(time_offset))
    })
    Nil
  })
}

pub external type RequestedFrame

// The returned 'long' can be passed to 'cancelAnimationFrame' - except we do not have any means to
// TODO Push the 'long' down into JS land, with the Animation, so we can
// make a mapping from Animation to RequestFrame and a `cancelFrame(Animation, msg) -> Cmd(m)`
// that (again in JS land) *can* cancel the appropriate request frame.
pub external fn request_animation_frame(f) -> RequestedFrame =
  "" "requestAnimationFrame"

pub external fn cancel_animation_frame(frame: RequestedFrame) -> Nil =
  "" "cancelAnimationFrame"
