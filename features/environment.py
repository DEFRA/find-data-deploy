import os

from selenium import webdriver

from webdriver_manager.chrome import ChromeDriverManager


def before_feature(context, feature):
    caps = {
        'name': 'Find Data Feature Tests',
        'build': '1.0',
        'screen_resolution': '1366x768',
        'record_video': 'true',
        'record_network': 'true',
        'take_snapshot': 'true'
    }

    context.base_url = 'http://localhost:5000'
    context.base_url = 'http://ckan'
    if 'TRAVIS' in os.environ:
        username = os.environ['SAUCE_USERNAME']
        access_key = os.environ['SAUCE_ACCESS_KEY']
        caps['tunnel-identifier'] = os.environ['TRAVIS_JOB_NUMBER']
        hub_url = '%s:%s@localhost:5000' % (username, access_key)
        context.driver = webdriver.Remote(
            desired_capabilities=caps,
            command_executor="http://%s/wd/hub" % hub_url
        )
    else:
        context.driver = webdriver.Chrome(
            ChromeDriverManager().install(),
            desired_capabilities=caps
        )


def after_feature(context, feature):
    context.driver.quit()
