import { HttpClient } from '@angular/common/http';
import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { environment } from 'src/environments/environment';
import { CarrouselItem } from '../CarrouselItem.model';
import { Todo } from '../models/todo.model';

@Injectable({
  providedIn: 'root'
})
export class TodoService {

  constructor(private http: HttpClient) {

  }

  getTodos(): Observable<Todo[]> {
    return this.http.get<Todo[]>(environment.apiurl + '/todo');
  }

  addTodo(todo: Todo): Observable<any> {
    return this.http.post(environment.apiurl + '/todo', todo);
  }

  updateTodo(todo: Todo): Observable<any> {
    return this.http.put(environment.apiurl + '/todo/' + todo._id, todo);
  }

  deleteTodo(todo: Todo): Observable<any> {
    return this.http.delete(environment.apiurl + '/todo/' + todo._id);
  }

  getCarrouselItems(): Observable<CarrouselItem[]> {
    return this.http.get<CarrouselItem[]>(environment.apiurl + '/carrousel');
  }


}
