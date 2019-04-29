import time

from behave import *
from selenium.webdriver import ActionChains
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.select import Select
from selenium.webdriver.support.wait import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC

use_step_matcher("re")


@step("they search for the title of a dataset")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url)
    input = context.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/div[1]/input')
    input.clear()
    input.send_keys('A Novel By Tolstoy')
    input.send_keys(Keys.ENTER)


@step("the search results are ordered by relevance")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    sort_select = Select(context.driver.find_element_by_id('dataset-sort'))
    option = sort_select.first_selected_option
    assert option.text == 'Relevance'


@step("the dataset is in the results list")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    datasets = []
    for item in context.driver.find_elements_by_class_name('dataset-heading'):
        datasets.append(item.find_elements_by_tag_name('a')[0].text)
    assert 'A Novel By Tolstoy' in datasets


@step("they search for a term in the description of a dataset")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url)
    input = context.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/div[1]/input')
    input.clear()
    input.send_keys('Foreign characters')
    input.send_keys(Keys.ENTER)


@step('they search for "organization:ne AND title:agri"')
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get(context.base_url)
    input = context.driver.find_element_by_xpath('//*[@id="dataset-search-form"]/div[1]/input')
    input.clear()
    input.send_keys('organization:david AND title:A Novel*')
    input.send_keys(Keys.ENTER)


@step('the search results are published by "Natural England"')
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    publishers = list(set(
        x.text for x in context.driver.find_elements_by_class_name('dataset-publisher-heading')
    ))
    assert len(publishers) == 1
    assert publishers[0] == 'Defra'


@step('the search results start with "agri"')
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    for item in context.driver.find_elements_by_class_name('dataset-heading'):
        assert 'agri' in item.find_elements_by_tag_name('a')[0].text.lower()


@step("they enter a search location")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    toggle = context.driver.find_element_by_class_name('location-search-toggle')
    toggle.find_element_by_tag_name('a').click()
    WebDriverWait(context.driver, 10).until(
        EC.presence_of_element_located((By.ID, 'location'))
    )
    time.sleep(1)
    input = context.driver.find_element_by_id('location')
    input.clear()
    input.send_keys('edin')
    WebDriverWait(context.driver, 10).until(
        EC.presence_of_element_located((By.CLASS_NAME, 'typeahead'))
    )
    dropdown = context.driver.find_element_by_class_name('typeahead')
    dropdown.find_elements_by_tag_name('a')[0].click()


@step("they draw a search box")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    toggle = context.driver.find_element_by_class_name('location-search-toggle')
    toggle.find_element_by_tag_name('a').click()
    WebDriverWait(context.driver, 10).until(
        EC.presence_of_element_located((By.CLASS_NAME, 'leaflet-zoom-animated'))
    )
    context.driver.find_element_by_xpath(
        '//*[@id="dataset-map-container"]/div[2]/div[2]/div/div/div/a'
    ).click()
    svg = context.driver.find_element_by_class_name('leaflet-zoom-animated')
    ac = ActionChains(context.driver)
    time.sleep(2)
    ac.move_to_element_with_offset(svg, 150, 150).click_and_hold().perform()
    ac.move_to_element_with_offset(svg, 450, 450).release().perform()
    context.driver.find_element_by_xpath('//*[@id="dataset-map-edit-buttons"]/a[2]').click()
