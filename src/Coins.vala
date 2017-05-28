using Coins;
namespace Coins {
    public class Application : Granite.Application {

        public Application () {
    		Object(
                application_id: "com.github.marplex.coins",
    			flags: ApplicationFlags.FLAGS_NONE
			);
    	}

        public override void activate () {
            var css_provider = new Gtk.CssProvider ();
            try {
                css_provider.load_from_path (Constants.DATADIR + "/coins/style/style.css");
            } catch (GLib.Error e) {
                stderr.printf ("I guess something is not working...\n" + e.message);
            }

            Gtk.StyleContext.add_provider_for_screen (
                Gdk.Screen.get_default (),
                css_provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            // Create the window of this application and show it
            MainWindow window = new MainWindow (this, "Coins");
            window.show_all ();
        }

        public static int main (string[] args) {
            Application app = new Application ();
            return app.run (args);
        }
    }
}
