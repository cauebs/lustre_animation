import gleam/float
import gleam/result
import lustre
import lustre/animation.{type Animator, type Timestamp}
import lustre/animation/interpolation.{lerp}
import lustre/attribute.{styles}
import lustre/effect.{type Effect}
import lustre/element.{text}
import lustre/element/html.{button, div, h3, span}
import lustre/event.{on_click}

pub type Msg {
  Left
  Right
  Top
  Bottom
  Tick(timestamp: Timestamp)
}

pub type Model {
  Model(x: Float, y: Float, animator: Animator(String, Float))
}

pub fn main() {
  lustre.application(init, update, render)
  |> lustre.start("#root", Nil)
}

fn init(_) {
  #(Model(0.5, 0.5, animation.empty()), effect.none())
}

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let m = case msg {
    Left -> {
      let new_animator =
        model.animator
        |> animation.add(
          "x",
          animation.create(with: lerp(model.x, 0.0), for: 2500.0),
        )
      Model(..model, animator: new_animator)
    }
    Right -> {
      let new_animator =
        model.animator
        |> animation.add(
          "x",
          animation.create(with: lerp(model.x, 1.0), for: 2500.0),
        )
      Model(..model, animator: new_animator)
    }
    Top -> {
      let new_animator =
        model.animator
        |> animation.add(
          "y",
          animation.create(with: lerp(model.y, 0.0), for: 2500.0),
        )
      Model(..model, animator: new_animator)
    }
    Bottom -> {
      let new_animator =
        model.animator
        |> animation.add(
          "y",
          animation.create(with: lerp(model.y, 1.0), for: 2500.0),
        )
      Model(..model, animator: new_animator)
    }
    Tick(timestamp) -> {
      let new_animator = animation.tick(model.animator, timestamp)
      let x = animation.value(new_animator, "x") |> result.unwrap(or: model.x)
      let y = animation.value(new_animator, "y") |> result.unwrap(or: model.y)
      Model(x: x, y: y, animator: new_animator)
    }
  }
  #(m, animation.effect(m.animator, Tick))
}

pub fn render(model: Model) {
  let sp = span([], [])
  let to_s = float.to_string
  div(
    [
      styles([
        #("display", "grid"),
        #("grid-template-rows", "1fr auto"),
        #("width", "100%"),
        #("height", "100%"),
      ]),
    ],
    [
      div(
        [
          styles([
            #("display", "grid"),
            #(
              "grid-template-rows",
              to_s(model.y) <> "fr auto " <> to_s(1.0 -. model.y) <> "fr",
            ),
            #(
              "grid-template-columns",
              to_s(model.x) <> "fr auto " <> to_s(1.0 -. model.x) <> "fr",
            ),
          ]),
        ],
        [sp, sp, sp, sp, h3([], [text("Move me around")]), sp, sp, sp, sp],
      ),
      div([], [
        button([on_click(Left)], [text("Move to the Left")]),
        button([on_click(Right)], [text("Move to the Right")]),
        button([on_click(Top)], [text("Move to the Top")]),
        button([on_click(Bottom)], [text("Move to the Bottom")]),
      ]),
    ],
  )
}
