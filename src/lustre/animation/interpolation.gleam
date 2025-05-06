//// This module contains functions that make simple interpolation functions to help you get started.

/// Make a function that linearly interpolate a floating point number from `start` to `stop`.
pub fn lerp(from start: Float, to stop: Float) -> fn(Float) -> Float {
  fn(t) { start +. t *. { stop -. start } }
}
