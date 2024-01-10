export const request_animation_frame = f => requestAnimationFrame(f)
export const cancel_animation_frame = id => cancelAnimationFrame(id)

export const after = (f, ms, dispatchTimeoutId) => {
    const timeoutId = setTimeout(f, ms)
    setTimeout(() => dispatchTimeoutId(timeoutId), 0)
}

export const cancel = timeoutId => clearTimeout(timeoutId)
