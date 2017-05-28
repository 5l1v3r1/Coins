using Soup;
namespace Coins.API {
    public class CoinMarketCap : Object {

        private string BASE_URL = "https://api.coinmarketcap.com/v1/ticker/%s/?limit=%s";
        private string URL;

		private int limit = 10;
		private string coin_id = "bitcoin";

        public signal void on_response (Gee.ArrayList<Json.Object> list);

        public CoinMarketCap () {}

        public void set_coin (string text) {
            this.coin_id = text;
        }

		public void set_limit (int limit) {
			this.limit = limit;
		}

        public void get_coins () {
			compose_url ();
            get_string_from_url (URL, (session, message) => {

                string json = (string) message.response_body.flatten ().data;
                Json.Parser parser = new Json.Parser ();
                parser.load_from_data (json, -1);

                var array_member = parser.get_root ().get_array ();
				Gee.ArrayList<Json.Object> list = new Gee.ArrayList<Json.Object> ();
				foreach (var item in array_member.get_elements ()) {
					list.add (item.get_object ());
				}

                on_response (list);
            });
        }

		private void compose_url () {
			URL = BASE_URL.printf(coin_id, limit.to_string ());
		}

        private void get_string_from_url (string url, Soup.SessionCallback? callback) {
            var session = new Soup.Session ();
            var message = new Soup.Message ("GET", url);

            session.queue_message (message, callback);
        }
    }
}
