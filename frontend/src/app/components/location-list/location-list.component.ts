import { Component, OnInit } from '@angular/core';
import { LocationsService } from 'src/app/services/locations.service';
import { Location } from 'src/app/models/location.model';

@Component({
  selector: 'app-location-list',
  templateUrl: './location-list.component.html',
  styleUrls: ['./location-list.component.css']
})
export class LocationListComponent implements OnInit {
  locations: Location[] = [];
  newLocation: Location = { id: '', name: '' };
  editMode: boolean = false;

  constructor(private locationsService: LocationsService) {}

  ngOnInit(): void {
    this.loadLocations();
  }

  loadLocations(): void {
    this.locationsService.getLocations().subscribe(data => this.locations = data);
  }

  addLocation(): void {
    const name = this.newLocation.name.trim();
    if (!name) return;

    const id = this.generateLocationId(name); // ✅ generate ID
    const newLoc: Location = { id, name };

    this.locationsService.addLocation(newLoc).subscribe(() => {
      this.newLocation = { id: '', name: '' };
      this.loadLocations();
    });
  }

  deleteLocation(id: string): void {
    this.locationsService.deleteLocation(id).subscribe(() => this.loadLocations());
  }

  updateLocation(loc: Location): void {
    this.locationsService.updateLocation(loc.id, loc).subscribe(() => this.loadLocations());
  }

  // ✅ ID generation logic
  private generateLocationId(name: string): string {
    const trimmed = name.trim().toLowerCase();

    if (trimmed.includes(' ')) {
      const initials = trimmed
        .split(' ')
        .filter(word => word.length > 0)
        .map(word => word[0])
        .join('');
      return 'loc-' + initials;
    } else {
      return 'loc-' + trimmed.slice(0, 3);
    }
  }
}
