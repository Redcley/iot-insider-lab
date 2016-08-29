class TechsController {
  /** @ngInject */
  constructor($http) {
    $http
      .get('src/app/techs/techs.json')
      .then(response => {
        this.techs = response.data;
      });
  }
}

export const techs = {
  templateUrl: 'src/app/techs/techs.html',
  controller: TechsController
};
