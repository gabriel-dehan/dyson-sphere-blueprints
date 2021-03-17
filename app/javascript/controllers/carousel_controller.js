import { Controller } from "stimulus"
import Swiper, { Navigation, Pagination } from 'swiper';

export default class extends Controller {
  static targets = [ "container" ]

  connect() {
    Swiper.use([Navigation, Pagination]);

    new Swiper(this.containerTarget, {
      speed: 300,
      autoHeight: true,
      allowTouchMove: false,
      direction: 'horizontal',
      loop: true,
      slidesPerView: 1,
      pagination: {
        el: '.swiper-pagination',
      },
      navigation: {
        nextEl: '.swiper-button-next',
        prevEl: '.swiper-button-prev',
      },
    });

  }
}
