import webgui, osproc, strutils, os

const cmdDD = "dd bs=4M status=progress oflag=sync if="
const htmlui = currentSourcePath().splitPath.head / "index.html"
let app = newWebView(htmlui, title = "Ballena Itcher", height = 700)

app.bindProcs("api"):
  proc runDD(o_d: string) =
    let fiso = o_d.split","[0]
    let dusb = o_d.split","[1]
    doAssert fiso.len > 0, "Error: Archivo ISO no puede ser string vacio"
    doAssert dusb.len > 0, "Error: Disco USB no puede ser string vacio"
    doAssert existsFile(fiso), "Error: Archivo ISO no encontrado"
    doAssert existsDir(dusb), "Error: Disco USB no encontrado"
    let cmd = cmdDD & fiso.quoteShell & " of=" & dusb.quoteShell
    echo cmd
    app.js("document.querySelector('#output').value = `" & cmd & "`")
    if dialogMessage("Confirmar".cstring, "Confirma Grabar ISO a USB?.".cstring, "yesno".cstring, "question".cstring, tdbNo) == 1.cint:
      let (output, exitCode) = execCmdEx(cmd)
      echo (output, exitCode)
      app.js("document.querySelector('#output').value = `" & output & "`")
      app.beep()
      app.setFocus()

  proc getIso() =
    let fiso = app.dialogOpen("Seleccionar 1 Archivo ISO")
    doAssert fiso.len > 0, "Error: Archivo ISO no puede ser string vacio"
    doAssert fiso.endsWith(".iso"), "Error: Archivo ISO debe ser '.iso' de extension de archivo"
    doAssert existsFile(fiso), "Error: Archivo ISO no encontrado"
    app.js("document.querySelector('#output').value = `Archivo ISO = " & $getFileSize(fiso) & " Bytes.`")
    app.js("document.querySelector('#iso').value = `" & fiso & "`")
    echo fiso

  proc getUsb() =
    let dusb = app.dialogOpenDir("Seleccionar 1 Disco USB")
    doAssert dusb.len > 0, "Error: Disco USB no puede ser string vacio"
    doAssert existsDir(dusb), "Error: Disco USB no encontrado"
    app.js("document.querySelector('#usb').value = `" & dusb & "`")
    echo dusb

app.run()
app.exit()
