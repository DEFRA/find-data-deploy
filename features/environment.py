import os

from selenium import webdriver

from webdriver_manager.chrome import ChromeDriverManager


def before_feature(context, feature):
    if 'TRAVIS' in os.environ:
        context.base_url = 'http://test_ckan:5000'
        chrome_options = webdriver.ChromeOptions()
        chrome_options.add_argument('--no-sandbox')
        chrome_options.add_argument('--headless')
        chrome_options.add_argument('--disable-gpu')
        context.driver = webdriver.Chrome(chrome_options=chrome_options)
        context.driver.implicitly_wait(10)

    else:
        context.base_url = 'http://ckan'
        context.driver = webdriver.Chrome(
            ChromeDriverManager().install(),
            desired_capabilities={
                'name': 'Find Data Feature Tests',
                'build': '1.0',
                'screen_resolution': '1366x768',
                'record_video': 'true',
                'record_network': 'true',
                'take_snapshot': 'true'
            }
        )


def after_feature(context, feature):
    context.driver.quit()
