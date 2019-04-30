from behave import *

use_step_matcher("re")


@given("a dataset")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.dataset_name = 'dogs-per-square-kilometre'
    context.dataset_title = 'Dogs per square kilometre'
    context.dataset_publisher = 'Department for Environment, Food & Rural Affairs'
    context.dataset_license = 'Open Government Licence'


@when("a user visits the page about the dataset")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.get('{}/dataset/{}'.format(
        context.base_url,
        context.dataset_name
    ))


@then("they see the dataset title")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    title = context.driver.find_elements_by_xpath('//h1[contains(text(), "{}")]'.format(context.dataset_title))
    assert len(title) == 1


@step("they see the dataset description")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    description = context.driver.find_elements_by_xpath(
        '//*[@id="content"]/div[3]/div/article/div/div/div[1]/p'
    )
    assert len(description) > 0


@step("they see the dataset publisher")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    publisher = context.driver.find_element_by_xpath(
        '//*[@id="content"]/div[3]/aside/div/div[1]/section/div/section/p'
    )
    assert publisher.text == context.dataset_publisher


@step("they see the dataset license")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    license = context.driver.find_element_by_class_name('license-text')
    assert license.text == context.dataset_license,\
        '"{}" != "{}"'.format(license.text, context.dataset_license)


@given("a dataset that is geospatial")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.dataset_name = 'dogs-per-square-kilometre'


@then("they see the dataset bounding box")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert(context.driver.find_element_by_id('dataset-map-container') is not None)


@step("they choose to see more like this")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.find_element_by_xpath('//*[@id="content"]/div[3]/div/article/div/ul/li[2]/a').click()


@then("they can see datasets that are similar to the dataset")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    assert len(context.driver.find_elements_by_class_name('dataset-item')) == 5


@given("a dataset with CSV resource")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.dataset_id = 'e4d5c6a5-72f6-4baf-8fc1-e2a463dbe4f2'
    context.dataset_name = 'cats-per-square-kilometre'


@step("they choose to preview the data")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    context.driver.find_element_by_xpath(
        '//*[@id="resource-e4d5c6a5-72f6-4baf-8fc1-e2a463dbe4f2"]/div/div/ul/li[1]/a'
    ).click()


@then("they can see a table view of the data")
def step_impl(context):
    """
    :type context: behave.runner.Context
    """
    container = context.driver.find_element_by_id('view-{}'.format(context.dataset_id))
    assert len(container.find_elements_by_tag_name('iframe')) == 1
