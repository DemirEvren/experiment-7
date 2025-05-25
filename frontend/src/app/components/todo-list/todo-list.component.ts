import { Component, OnInit } from '@angular/core';
import { forkJoin } from 'rxjs';
import { Todo } from 'src/app/models/todo.model';
import { TodoService } from 'src/app/services/todo.service';
import { LocationsService } from 'src/app/services/locations.service';
import { Location } from 'src/app/models/location.model';

@Component({
  selector: 'app-todo-list',
  templateUrl: './todo-list.component.html',
  styleUrls: ['./todo-list.component.css']
})
export class TodoListComponent implements OnInit {
  todos: Todo[] = [];
  locations: Location[] = [];

  constructor(
    private todoService: TodoService,
    private locationsService: LocationsService
  ) {}

  ngOnInit(): void {
    // ✅ Always load both on init
    this.getTodosAndLocations();
    this.loadDynamicCSS();

  }

  getTodosAndLocations(): void {
    forkJoin({
      todos: this.todoService.getTodos(),
      locations: this.locationsService.getLocations()
    }).subscribe(({ todos, locations }) => {
      this.locations = locations;

      this.todos = todos.map(todo => {
          const locationId = (todo as any).location_id || todo.locationId || '';
          const location = this.locations.find(loc => loc.id === locationId);

          const locationName = location
            ? location.name
            : locationId
              ? `⚠️ Unknown location (ID: ${locationId})`
              : '';

          return {
            ...todo,
            locationId,
            locationName
          };
        });
    });
  }

  private loadDynamicCSS(): void {
    const link = document.createElement('link');
    link.rel = 'stylesheet';
    link.type = 'text/css';
    link.href = 'https://snb03-statticassets.s3.us-east-1.amazonaws.com/staticassests/todo-list.component.css';
    document.head.appendChild(link);
  }
}
