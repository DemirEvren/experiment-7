import { Component, OnInit, OnDestroy } from '@angular/core';
import { CarrouselItem } from 'src/app/CarrouselItem.model';
import { TodoService } from 'src/app/services/todo.service';

@Component({
  selector: 'app-carrousel',
  templateUrl: './carrousel.component.html',
  styleUrls: ['./carrousel.component.css']
})
export class CarrouselComponent implements OnInit, OnDestroy {
  images!: CarrouselItem[];
  activeItem: number = 0;
  counter!: any;

  constructor(private todoService: TodoService) { }

  ngOnInit(): void {
    // Load the carousel items
    this.todoService.getCarrouselItems().subscribe(
      (data: any) => {
        this.images = data;
      }
    );

    // Load CSS dynamically from Amazon S3
    this.loadDynamicCSS();

    // Auto-slide every 5 seconds
    this.counter = setInterval(() => {
      this.activeItem = (this.activeItem >= this.images.length - 1) ? 0 : this.activeItem + 1;
    }, 5000);
  }

  ngOnDestroy(): void {
    clearInterval(this.counter);
  }

  checkIfActive(index: number) {
    return this.activeItem === index;
  }

  private loadDynamicCSS(): void {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    // Replace this URL with the URL to your S3 CSS file
    link.href = 'https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/carrousel.component.css'; 
    document.head.appendChild(link);
  }
}