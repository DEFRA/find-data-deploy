from locust import HttpLocust, TaskSet, task


class UserTasks(TaskSet):

    @task
    def index(self):
        self.client.get('/')

    @task
    def text_search(self):
        self.client.get(
            '/dataset?q=dogs&sort=score+desc%2C+metadata_modified+desc&ext_bbox=&ext_prev_extent='
            '-4.21875%2C54.97761367069628%2C-4.21875%2C54.97761367069628')

    @task
    def geo_search(self):
        self.client.get(
            '/dataset?q=&sort=score+desc%2C+metadata_modified+desc&ext_bbox=-0.15017071111323585%2C51.324482817119865'
            '%2C-0.10035989021248179%2C51.34686119857052&ext_prev_extent=-0.15017071111323585%2C51.324482817119865%2C'
            '-0.10035989021248179%2C51.34686119857052'
        )

    @task
    def dataset1(self):
        self.client.get('/dataset/historic-landfill-sites-quarterly-summary')

    @task
    def dataset2(self):
        self.client.get('/dataset/broads-authority-inspire-ogc-wfs-service')

    @task
    def publishers(self):
        self.client.get('/publisher')

    @task
    def publisher_search(self):
        self.client.get('/publisher?q=apha&sort=title+asc')

    @task
    def publisher1(self):
        self.client.get('/publisher/apha')

    @task
    def publisher2(self):
        self.client.get('/publisher/mmo')


class WebsiteUser(HttpLocust):
    task_set = UserTasks
