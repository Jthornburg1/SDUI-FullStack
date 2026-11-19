import json
import threading
import unittest
from http.server import ThreadingHTTPServer
from unittest.mock import patch
from urllib.error import HTTPError
from urllib.request import ProxyHandler, Request, build_opener

from server import Handler, load_forms


class QuietHandler(Handler):
    def log_message(self, *args):
        pass


class ServerTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.server = ThreadingHTTPServer(("127.0.0.1", 0), QuietHandler)
        cls.thread = threading.Thread(target=cls.server.serve_forever, daemon=True)
        cls.thread.start()
        cls.base = f"http://127.0.0.1:{cls.server.server_port}"
        cls.opener = build_opener(ProxyHandler({}))

    @classmethod
    def tearDownClass(cls):
        cls.server.shutdown()
        cls.server.server_close()
        cls.thread.join()

    def get(self, path):
        return self.opener.open(self.base + path, timeout=5)

    def test_catalog_and_all_definitions(self):
        with self.get('/api/forms') as response:
            self.assertEqual(response.headers.get_content_type(), 'application/json')
            self.assertEqual(response.headers['Cache-Control'], 'no-store')
            catalog = json.load(response)
        self.assertEqual(catalog['schemaVersion'], 1)
        self.assertEqual({f['id'] for f in catalog['forms']}, {'contact', 'appointment', 'feedback'})
        for entry in catalog['forms']:
            with self.get(entry['path']) as response:
                form = json.load(response)
            self.assertEqual(form['id'], entry['id'])
            fields = [f for s in form['sections'] for f in s['fields']]
            ids = {f['id'] for f in fields}
            self.assertEqual(len(ids), len(fields))
            for field in fields:
                if 'visibleWhen' in field:
                    self.assertIn(field['visibleWhen']['fieldId'], ids)

    def test_health_and_query(self):
        with self.get('/health') as response:
            self.assertEqual(json.load(response)['status'], 'ok')
        with self.get('/api/forms/contact/?example=1') as response:
            self.assertEqual(json.load(response)['id'], 'contact')

    def test_missing_routes(self):
        for path in ['/missing', '/api/forms/missing', '/api/forms/../server.py']:
            with self.assertRaises(HTTPError) as result:
                self.get(path)
            self.assertEqual(result.exception.code, 404)
            self.assertEqual(json.load(result.exception)['error']['code'], 'not_found')

    def test_read_only(self):
        with self.assertRaises(HTTPError) as result:
            self.opener.open(Request(self.base + '/api/forms/contact', data=b'{}', method='POST'), timeout=5)
        self.assertEqual(result.exception.code, 405)
        self.assertEqual(result.exception.headers['Allow'], 'GET')
        self.assertEqual(json.load(result.exception)['error']['code'], 'method_not_allowed')

    def test_bad_definition_returns_json_error(self):
        with patch('server.load_forms', side_effect=ValueError('invalid JSON')):
            with self.assertRaises(HTTPError) as result:
                self.get('/api/forms')
        self.assertEqual(result.exception.code, 500)
        self.assertEqual(json.load(result.exception)['error']['code'], 'invalid_form_definition')

    def test_definitions_are_reloaded(self):
        forms = load_forms()
        forms['contact']['title'] = 'Updated title'
        with patch('server.load_forms', return_value=forms):
            with self.get('/api/forms/contact') as response:
                self.assertEqual(json.load(response)['title'], 'Updated title')


if __name__ == '__main__':
    unittest.main()
