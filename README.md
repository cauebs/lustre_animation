# Lustre Animation

The basic usage is
 * Create an animator and keep it in your model
 * Create animations and add them to the animator
 * Call `animation.effect()` on your value and let your Lustre `update()` function return it.
   This will cause a dispatch on the next JS animation frame, unless all animations have finished (and auto-removed)
 * Update the animator with the new time you received
 * Evaluate for each animation you are interested in.

e.g. like this:
```gleam
import lustre/animation as a
import lustre/animation/interpolation.{lerp}

pub type Msg {
  Trigger
  Tick(a.Timestamp)
}

pub fn update(model: Model, msg: Msg) {
  let m = case msg {
    Trigger -> {
      let animation = a.create("id", with: lerp(1.0, 2.0), for: 0.25)
      let new_anim = a.add(model.animator, animation)
      Model(1.0, animator: new_anim)
    }
    Tick(t) -> {
      let new_anim = a.tick(model.animator, t)
      Model(new_anim)
    }
  }
  #(m, animation.effect(m.animator, Tick))
}

pub fn view(model: Model) -> Msg {
  case a.value(new_anim, "id") {
    Ok(value) -> todo
    Err(_) -> todo
  }
}
```

In the above `type Model` and `init` have been omitted.

There are fully functional examples animations in the `test/` directory,
which you can build by
```bash
gleam test
npx vite
````

and then pointing your browser to the URL that vite indicates.

## TODO
* quadratic, cubic, etc interpolators
