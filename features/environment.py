from selenium import webdriver

from webdriver_manager.chrome import ChromeDriverManager

# TODO: Read from env?
username = 'defra'
password = 'finddata'


def before_feature(context, feature):
    caps = {
        'name': 'Find Data Feature Tests',
        'build': '1.0',
        'screen_resolution': '1366x768',
        'record_video': 'true',
        'record_network': 'true',
        'take_snapshot': 'true'
    }

    context.base_url = 'http://ckan'
    context.driver = webdriver.Chrome(
        ChromeDriverManager().install(),
        desired_capabilities=caps
    )


def after_feature(context, feature):
    context.driver.quit()
