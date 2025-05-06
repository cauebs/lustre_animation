import birdie
import gleam/float
import gleam/int
import gleam/list
import gleam/string
import lustre/animation as a
import lustre/animation/interpolation.{lerp}

pub fn basic_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000)")
}

pub fn delay_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.delay(500.0)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> delay(500)")
}

pub fn repeat_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.repeat(3)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> repeat(3)")
}

pub fn repeat_forever_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.repeat_forever()
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> repeat_forever()")
}

pub fn reverse_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.reverse()
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> reverse()")
}

pub fn chain_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> chain(lerp(6, 8, 2000))")
}

pub fn delay_then_repeat_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.delay(500.0)
  |> a.repeat(3)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> delay(500) |> repeat(3)")
}

pub fn delay_then_reverse_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.delay(500.0)
  |> a.reverse()
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> delay(500) |> reverse()")
}

pub fn delay_then_chain_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.delay(500.0)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> delay(500) |> chain(lerp(6, 8, 2000))")
}

pub fn repeat_then_delay_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.repeat(3)
  |> a.delay(500.0)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> repeat(3) |> delay(500)")
}

pub fn repeat_then_reverse_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.repeat(3)
  |> a.reverse()
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> repeat(3) |> reverse()")
}

pub fn repeat_then_chain_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.repeat(3)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> repeat(3) |> chain(lerp(6, 8, 2000))")
}

pub fn reverse_then_delay_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.reverse()
  |> a.delay(500.0)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> reverse() |> delay(500)")
}

pub fn reverse_then_repeat_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.reverse()
  |> a.repeat(3)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> reverse() |> repeat(3)")
}

pub fn reverse_then_chain_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.reverse()
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> reverse() |> chain(lerp(6, 8, 2000))")
}

pub fn chain_then_delay_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> a.delay(500.0)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> chain(lerp(6, 8, 2000)) |> delay(500)")
}

pub fn chain_then_repeat_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> a.repeat(3)
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> chain(lerp(6, 8, 2000)) |> repeat(3)")
}

pub fn chain_then_reverse_test() {
  a.create(with: lerp(1.0, 5.0), for: 1000.0)
  |> a.chain(a.create(with: lerp(6.0, 8.0), for: 2000.0))
  |> a.reverse()
  |> make_snapshot()
  |> birdie.snap("lerp(1, 5, 1000) |> chain(lerp(6, 8, 2000)) |> reverse()")
}

pub fn complex_compositions_test() {
  let basic1 = a.create(with: lerp(1.0, 5.0), for: 1000.0)
  let basic2 = a.create(with: lerp(6.0, 8.0), for: 2000.0)

  basic1
  |> a.delay(500.0)
  |> a.repeat(3)
  |> a.reverse()
  |> a.chain(basic2)
  |> make_snapshot()
  |> birdie.snap(
    "lerp(1, 5, 1000) |> delay(500) |> repeat(3) |> reverse |> chain(lerp(6, 8, 2000))",
  )

  basic1
  |> a.chain(basic2)
  |> a.delay(500.0)
  |> a.repeat(3)
  |> a.reverse()
  |> make_snapshot()
  |> birdie.snap(
    "lerp(1, 5, 1000) |> chain(lerp(6, 8, 2000)) |> delay(500) |> repeat(3) |> reverse",
  )

  basic1
  |> a.reverse()
  |> a.chain(basic2)
  |> a.delay(500.0)
  |> a.repeat(3)
  |> make_snapshot()
  |> birdie.snap(
    "lerp(1, 5, 1000) |> reverse |> chain(lerp(6, 8, 2000)) |> delay(500) |> repeat(3)",
  )

  basic1
  |> a.repeat(3)
  |> a.reverse()
  |> a.chain(basic2)
  |> a.delay(500.0)
  |> make_snapshot()
  |> birdie.snap(
    "lerp(1, 5, 1000) |> repeat(3) |> reverse |> chain(lerp(6, 8, 2000)) |> delay(500)",
  )
}

fn make_snapshot(animation: a.Animation(a)) -> String {
  let structure = animation |> string.inspect()
  let values =
    animation
    |> evaluate_over_time(step: 500.0)
    |> list.map(string.inspect)
    |> string.join("\n")
  structure <> "\n" <> values
}

const max_steps = 50

fn evaluate_over_time(
  animation: a.Animation(a),
  step step: Float,
) -> List(#(a.Timestamp, a)) {
  let animator = a.empty() |> a.add("a", animation)

  let ts =
    list.range(0, max_steps)
    |> list.map(int.to_float)
    |> list.map(float.multiply(_, step))
    |> list.map(a.timestamp_from_millis)

  let #(_animator, values) = {
    use #(animator, values), t <- list.fold_until(ts, #(animator, []))

    let animator = a.tick(animator, t)
    case a.value(animator, "a") {
      Ok(value) -> list.Continue(#(animator, [#(t, value), ..values]))
      Error(_) -> list.Stop(#(animator, values))
    }
  }

  list.reverse(values)
}
