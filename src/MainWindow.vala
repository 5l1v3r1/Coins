using Granite;
namespace Coins {
    public class MainWindow : Gtk.Dialog {

        private Gtk.Box content;
		private Coins.API.CoinMarketCap coins_api;
		private Gee.ArrayList<Json.Object> coins_list;

		private Gtk.Image coin_image;
		private Gtk.Stack stack;

        public MainWindow (Coins.Application application, string title) {
            Object (application: application);

            this.title = title;
            this.window_position = Gtk.WindowPosition.CENTER;
			this.resizable = false;
			this.destroy.connect (() => {
				close();
			});

			coins_list = new Gee.ArrayList<Json.Object> ();
			coins_api = new Coins.API.CoinMarketCap ();

			Gtk.HeaderBar header_bar = new Gtk.HeaderBar ();
			header_bar.title = "Coins";
			header_bar.show_close_button = true;

			Gtk.ToggleButton detail_button = new Gtk.ToggleButton ();
			Gtk.Image icon = new Gtk.Image.from_icon_name ("view-more-horizontal-symbolic", Gtk.IconSize.MENU);
			detail_button.add (icon);
			detail_button.toggled.connect (() => {
				if(detail_button.active) stack.set_visible_child_name ("Detail");
				else stack.set_visible_child_name ("Summary");
			});

			Gtk.Entry search_entry = new Gtk.Entry ();
        	search_entry.primary_icon_name = "system-search";
			search_entry.vexpand = true;
			search_entry.activate.connect (() => {
				detail_button.active = false;
				coins_api.set_coin (search_entry.get_text ());
				receive_coins ();
			});

			header_bar.pack_start (search_entry);
			header_bar.pack_end (detail_button);
			this.set_titlebar (header_bar);

			coin_image = new Gtk.Image ();
			coin_image.width_request = 64;
			coin_image.height_request = 64;
			coin_image.icon_name = "image-x-generic";
			coin_image.halign = Gtk.Align.END;

            content = get_content_area () as Gtk.Box;
			content.height_request = 90;
			receive_coins ();
        }

		private void receive_coins () {
			coins_api.on_response.connect ((list) =>  {
				if (list.size > 0) {
					coins_list.add_all (list);
					update_ui ();
				}
			});
			coins_api.get_coins ();
		}

        private void update_ui () {
			clear_current ();

			stack = new Gtk.Stack ();
            stack.valign = Gtk.Align.CENTER;
            stack.transition_duration = 200;
            stack.transition_type = Gtk.StackTransitionType.SLIDE_LEFT_RIGHT;

			Gtk.Box box = new Gtk.Box(Gtk.Orientation.HORIZONTAL, 0);
			box.vexpand = true;
			var element = coins_list.get (0);

			var url = "https://files.coinmarketcap.com/static/img/coins/64x64/%s.png".printf(element.get_string_member ("id"));
			update_image.begin (url);
			box.pack_start (coin_image, true, true, 10);

			Gtk.Box coin_name = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			Gtk.Label name = new Gtk.Label (element.get_string_member ("name"));
			coin_name.get_style_context ().add_class ("name");
			name.halign = Gtk.Align.START;

			Gtk.Box box_summary = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

			Gtk.Label symbol = new Gtk.Label (element.get_string_member ("symbol"));
			symbol.get_style_context ().add_class ("symbol");
			symbol.halign = Gtk.Align.START;

			coin_name.pack_start (name, false, true, 0);
			coin_name.pack_start (symbol, false, true, 0);
			coin_name.vexpand = true;
			coin_name.valign = Gtk.Align.CENTER;
			
			box_summary.pack_start (coin_name, true, true, 20);


			Gtk.Box coin_price = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			Gtk.Label price_usd = new Gtk.Label (element.get_string_member ("price_usd") + " $");
			price_usd.get_style_context ().add_class ("price_usd");
			price_usd.halign = Gtk.Align.END;

			Gtk.Label price_btc = new Gtk.Label (element.get_string_member ("price_btc") + " BTC");
			price_btc.get_style_context ().add_class ("price_btc");
			price_btc.halign = Gtk.Align.END;

			coin_price.pack_start (price_usd, false, true, 0);
			coin_price.pack_start (price_btc, false, true, 0);
			coin_price.vexpand = true;
			coin_price.valign = Gtk.Align.CENTER;

			box_summary.pack_start (coin_price, true, true, 20);


			var percentage_box = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);

			Gtk.Box 1h_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			1h_box.valign = Gtk.Align.CENTER;
			var percentage_1h_title = new Gtk.Label (_("% Change 1h"));
			percentage_1h_title.get_style_context ().add_class ("percent_title");
			var percentage_1h = new Gtk.Label (element.get_string_member ("percent_change_1h") + " %");
			if (element.get_string_member ("percent_change_1h").substring (0, 1) == "-") {
				percentage_1h.get_style_context ().add_class ("percent_red");
			}else percentage_1h.get_style_context ().add_class ("percent_green");
			
			1h_box.pack_start (percentage_1h_title, false, true, 0);
			1h_box.pack_start (percentage_1h, false, true, 0);

			Gtk.Box 24h_box = new Gtk.Box (Gtk.Orientation.VERTICAL, 0);
			24h_box.valign = Gtk.Align.CENTER;
			var percentage_24h_title = new Gtk.Label (_("% Change 24h"));
			percentage_24h_title.get_style_context ().add_class ("percent_title");
			var percentage_24h = new Gtk.Label (element.get_string_member ("percent_change_24h") + " %");
			if (element.get_string_member ("percent_change_24h").substring (0, 1) == "-") {
				percentage_24h.get_style_context ().add_class ("percent_red");
			}else percentage_24h.get_style_context ().add_class ("percent_green");
			
			24h_box.pack_start (percentage_24h_title, false, true, 0);
			24h_box.pack_start (percentage_24h, false, true, 0);

			percentage_box.pack_start (1h_box, true, true, 10);
			percentage_box.pack_start (24h_box, true, true, 10);

			stack.add_named (box_summary, "Summary");
			stack.add_named (percentage_box, "Detail");
			box.pack_start (stack, true, true, 0);
			content.pack_start (box, true, true, 10);
			show_all ();
			coins_list.clear ();
        }

		private void clear_current () {
			content.forall ((element) => content.remove (element));
		}

		private async void update_image (string url) {
			Gdk.Pixbuf pixbuf = yield download_pixbuf (url);
			coin_image.pixbuf = pixbuf;
		}

		private async Gdk.Pixbuf? download_pixbuf (string url, GLib.Cancellable? cancellable = null) {

			Gdk.Pixbuf? result = null;
			var msg = new Soup.Message ("GET", url);
			GLib.SourceFunc cb = download_pixbuf.callback;

			new Soup.Session ().queue_message (msg, (_s, _msg) => {
			if (cancellable.is_cancelled ()) {
				cb ();
				return;
			}
			try {
				var in_stream = new MemoryInputStream.from_data (_msg.response_body.data,
																GLib.g_free);
				result = new Gdk.Pixbuf.from_stream (in_stream, cancellable);
			} catch (GLib.Error e) {
				warning (e.message);
			} finally {
				cb ();
			}
			});
			yield;

			return result;
		}

    }
}
