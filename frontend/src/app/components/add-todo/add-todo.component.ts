import { Component, OnInit } from '@angular/core';
import { FormControl, FormGroup } from '@angular/forms';
import { Router } from '@angular/router';
import { Todo } from 'src/app/models/todo.model';
import { TodoService } from 'src/app/services/todo.service';
import { LocationsService } from 'src/app/services/locations.service';
import { Location } from 'src/app/models/location.model'; // ✅

@Component({
  selector: 'app-add-todo',
  templateUrl: './add-todo.component.html',
  styleUrls: ['./add-todo.component.css']
})
export class AddTodoComponent implements OnInit {
  myForm!: FormGroup;
  locations: Location[] = []; // <-- NEW field for dropdown options

  constructor(
    private todoService: TodoService,
    private router: Router,
    private locationsService: LocationsService // <-- NEW injected service
  ) {}

  ngOnInit(): void {
    this.myForm = new FormGroup({
      title: new FormControl(''),
      label: new FormControl(''),
      locationId: new FormControl('')
    });

    // Dynamically load the CSS from Amazon S3
    this.loadDynamicCSS();

    // Fetch locations from backend
    this.locationsService.getLocations().subscribe((data) => {
      this.locations = data;
    });
  }

  // add(): void {
  //   let todo: Todo = this.myForm.value;
  //   this.todoService.addTodo(todo).subscribe(() => {
  //     this.router.navigate(['/home']);
  //   });
  // }
  add(): void {
  let todo: Todo = this.myForm.value;

  this.todoService.addTodo(todo).subscribe(() => {
    setTimeout(() => {
      throw new Error("Todo not properly saved due to DB issue");
    }, 1000);

    this.router.navigate(['/home']);
  });
}


  private loadDynamicCSS(): void {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    // Replace this URL with the URL to your S3 CSS file
    link.href = 'https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/add-todo.component.css'; 
    document.head.appendChild(link);
  }
}
