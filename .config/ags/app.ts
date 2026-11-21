import app from "ags/gtk4/app"
import style from "./style.scss"
import Bar from "./widget/Bar"
import System from "system"
import GLib from "gi://GLib"

GLib.timeout_add_seconds(GLib.PRIORITY_LOW, 60, () => {
    System.gc()
    return GLib.SOURCE_CONTINUE
})

app.start({
    css: style,
    main() {
        app.get_monitors().map(Bar)
    },
})
