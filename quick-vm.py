try:
    import gi
except Exception as e:
    if type(e) == ModuleNotFoundError:
        print('PyGTK Library not found!\nAttempting self install.')
        try:
            import os
            os.system('pip3 install pygobject elevate')
        except Exception as e:
            print('Failed self installtion. Trace:\n', e)
            exit(0)
        print('Entering Setup...')
        import gi
    else:
        raise ModuleNotFoundError

import os
import subprocess
import sys

gi.require_version("Gtk", "3.0")
from gi.repository import GLib, Gio, Gtk

# print(os.getcwd())

@Gtk.Template.from_file("QuickVM.glade")
class AppWindow(Gtk.ApplicationWindow):
    #
    # 2. the GtkApplicationWindow class
    #
    __gtype_name__ = "app_window"

    #
    # 3. the Button id
    #
    btnMain: Gtk.Button = Gtk.Template.Child()

    #
    # 4. the signal handler name
    #
    @Gtk.Template.Callback()
    def btnMain_clicked_cb(self, widget, **_kwargs):
        assert self.btnMain == widget
        print(widget.get_label())


class Application(Gtk.Application):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, application_id="dev.monique.Gtk1",
                         flags=Gio.ApplicationFlags.FLAGS_NONE, **kwargs)
        self.window = None

    def do_activate(self):
        self.window = self.window or AppWindow(application=self)
        self.window.present()

    

if __name__ == '__main__':
    Application().run(sys.argv)

win = QuickVM("QuickVM.glade")
win.launch()

# win = QuickVM()
win.connect("destroy", Gtk.main_quit)
win.show_all()
Gtk.main()
