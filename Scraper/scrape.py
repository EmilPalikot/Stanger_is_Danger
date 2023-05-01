import time
import json
import logging
import requests
from collections import OrderedDict

from requests.packages.urllib3.exceptions import InsecureRequestWarning
requests.packages.urllib3.disable_warnings(InsecureRequestWarning)


logging.basicConfig(level=logging.NOTSET,
                    format="%(asctime)s %(levelname)8s | %(name)s | %(message)s",
                    datefmt="%Y/%m/%d %H:%M:%S")
logger = logging.getLogger()
file_handler = logging.FileHandler(filename='./scraper.log', mode='a')
file_handler.setFormatter(logging.Formatter(fmt="%(asctime)s %(levelname)8s | %(name)s | %(message)s",
                                            datefmt="%Y/%m/%d %H:%M:%S"))
logger.addHandler(file_handler)


class Scraper(object):
    _BASE_URL = "https://www.blablacar.co.uk"

    def __init__(self):
        """
        Create Scraper object
        """
        self._logger = logging.getLogger(self.__class__.__name__)
        self._create_session()

    @staticmethod
    def _super_proxy():
        """
        username = ''
        password = ''
        port = 22225
        session_id = random.random()
        return f'http://{username}-session-{session_id}:{password}@zproxy.lum-superproxy.io:{port}'
        """
        #return 'http://127.0.0.1:8888'

    def _create_session(self):
        headers = OrderedDict([
            ("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0"),
            ("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"),
            ("Accept-Language", "en-US,en;q=0.9"),
            ("Accept-Encoding", "gzip, deflate"),  # , br
            ("DNT", "1"),
            ("Connection", "keep-alive"),
            ("Upgrade-Insecure-Requests", "1"),
            ("Pragma", "no-cache"),
            ("Cache-Control", "no-cache"),
        ])
        self.session = requests.session()
        self.session.headers = headers
        self.session.verify = False
        proxy = self._super_proxy()
        self.session.proxies = {
            'http': proxy,
            'https': proxy,
        }
        self._logger.debug('Start session')
        self.session.get(self._BASE_URL)

    def run(self, trip_id):
        """
        Load pages and scrape them. Return:
            drivers' name
            ride description
            and passenger' names (if there are any)
            driver reviews

        :param trip_id:
        :return:
        """
        result = {
            "ride": {},
            "rating": []
        }

        self._logger.info('get trip data')
        data = {
            "source": "CARPOOLING",
            "id": trip_id,
        }

        response = self.session.get("{}/trip".format(self._BASE_URL), params=data)
        self._logger.debug("URL: {}".format(response.url))

        if not response.ok:
            self._logger.debug("FAULT: {} {}".format(response.status_code, response.reason))
            return False

        time.sleep(5)
        self._logger.debug("get ride data")
        self.session.headers = OrderedDict([
            ("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0"),
            ("Accept", "application/json"),
            ("Accept-Language", "en_GB"),
            ("Accept-Encoding", "gzip, deflate, br"),
            ("Referer", self._BASE_URL),
            ("Content-Type", "application/json"),
            ("X-Blablacar-Accept-Endpoint-Version", "4"),
            ("x-locale", "en_GB"),
            ("x-visitor-id", scraper.session.cookies['vstr_id']),
            ("x-currency", "GBP"),
            ("x-correlation-id", "ecffc2e4-1adf-4ce1-be44-9493a4c42504"),
            ("x-client", "SPA|1.0.0"),
            ("x-forwarded-proto", "https"),
            ("Authorization", "Bearer {}".format(scraper.session.cookies['app_token'])),
            ("Origin", "https://www.blablacar.co.uk"),
            ("DNT", "1"),
            ("Connection", "keep-alive"),
            ("Pragma", "no-cache"),
            ("Cache-Control", "no-cache"),
            ("TE", "Trailers"),
        ])
        data = {
            "source": "CARPOOLING",
            "id": trip_id,
            "requested_seats": "1",
        }
        response = self.session.get("https://edge.blablacar.co.uk/ride", params=data)
        self._logger.debug("URL: {}".format(response.url))

        if not response.ok:
            self._logger.debug("FAULT: {} {}".format(response.status_code, response.reason))
            return False

        ride_data = response.json()

        result['ride'] = ride_data

        time.sleep(5)
        self._logger.debug("get reviews data")
        self.session.headers = OrderedDict([
            ("User-Agent", "Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:76.0) Gecko/20100101 Firefox/76.0"),
            ("Accept", "application/json"),
            ("Accept-Language", "en_GB"),
            ("Accept-Encoding", "gzip, deflate, br"),
            ("Referer", self._BASE_URL),
            ("Content-Type", "application/json"),
            ("X-Blablacar-Accept-Endpoint-Version", "4"),
            ("x-locale", "en_GB"),
            ("x-visitor-id", scraper.session.cookies['vstr_id']),
            ("x-currency", "GBP"),
            ("x-correlation-id", "ecffc2e4-1adf-4ce1-be44-9493a4c42504"),
            ("x-client", "SPA|1.0.0"),
            ("x-forwarded-proto", "https"),
            ("Authorization", "Bearer {}".format(scraper.session.cookies['app_token'])),
            ("Origin", "https://www.blablacar.co.uk"),
            ("DNT", "1"),
            ("Connection", "keep-alive"),
            ("Pragma", "no-cache"),
            ("Cache-Control", "no-cache"),
            ("TE", "Trailers"),
        ])

        page_num = 0
        total_pages = 1
        while page_num < total_pages:
            page_num += 1
            data = {
                "page": page_num,
                "limit": "100",
            }
            response = self.session.get("https://edge.blablacar.co.uk/api/v2/users/{}/rating".format(
                ride_data['driver']['id']), params=data)
            self._logger.debug("URL: {}".format(response.url))

            if not response.ok:
                self._logger.debug("FAULT: {} {}".format(response.status_code, response.reason))
                return False

            ratings_data = response.json()
            result['rating'].append(ratings_data)

            total_pages = ratings_data['pager'].get('pages', total_pages)

        return result


if __name__ == '__main__':
    TRIPS = [
        "1977112692-la-chapelle-saint-mesmin-bordeaux",
        "1977069284-paris-lyon",
        "1977163610-paris-saran",
        "1976423696-paris-ouistreham",
        "1975623953-bobigny-villenave-d-ornon",
    ]

    for trip_id in TRIPS:
        scraper = Scraper()
        data = scraper.run(trip_id)
        if data:
            with open('{}.json'.format(trip_id), 'w') as f:
                json.dump(data, f)

        time.sleep(10)

    logging.debug('Done.')
