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
  errorMessage: string | null = null;
  successMessage: string | null = null;
  triggerAnimation = false;

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

    const id = this.generateLocationId(name);
    const newLoc: Location = { id, name };

    this.locationsService.addLocation(newLoc).subscribe({
      next: () => {
        this.newLocation = { id: '', name: '' };
        this.loadLocations();
        this.errorMessage = null;
        this.successMessage = 'Location created successfully!';
        setTimeout(() => this.successMessage = null, 5000);
      },
      error: (err) => {
        this.successMessage = null;
        if (err.status === 404 || err.status === 409 || err.error?.message?.includes('already exist')) {
          this.errorMessage = 'Location already exists!';
          this.triggerAnimation = false;
          setTimeout(() => {
            this.triggerAnimation = true;
          }, 10);
          setTimeout(() => this.errorMessage = null, 5000);
        }
      }
    });
  }

 deleteLocation(id: string): void {
  this.locationsService.deleteLocation(id).subscribe({
    next: () => {
      this.loadLocations();
      this.errorMessage = null;
      this.successMessage = 'Location deleted successfully!';
      setTimeout(() => {
        this.successMessage = null;
      }, 5000);
    },
    error: (err) => {
      console.error('DELETE ERROR:', err);
      this.successMessage = null;
      this.errorMessage = 'Failed to delete location.';
      setTimeout(() => {
        this.errorMessage = null;
      }, 5000);
    }
  });
}


  updateLocation(loc: Location): void {
  const originalId = loc.id;
  const originalName = this.locations.find(l => l.id === originalId)?.name || loc.name;

  const newId = this.generateLocationId(loc.name);
  const newName = loc.name.trim();

  if (!newName) return;

  // ✅ Check if a location with the new ID already exists (but not the current one)
  const duplicate = this.locations.find(l => l.id === newId && l.id !== originalId);

  if (duplicate) {
    this.successMessage = null;
    this.errorMessage = 'Cannot Update: Location already exists!';
    
    // 🔁 Revert the input back to the original name
    const current = this.locations.find(l => l.id === originalId);
    if (current) current.name = originalName;

    setTimeout(() => {
      this.errorMessage = null;
    }, 5000);

    return; // 🚫 Stop here — don't update
  }

  // ✅ If no duplicate, proceed to delete and re-add
  const updatedLocation: Location = {
    id: newId,
    name: newName
  };

  this.locationsService.deleteLocation(originalId).subscribe(() => {
    this.locationsService.addLocation(updatedLocation).subscribe({
      next: () => {
        this.loadLocations();
        this.errorMessage = null;
        this.successMessage = 'Location updated successfully!';
        setTimeout(() => this.successMessage = null, 5000);
      },
      error: (err) => {
        if (err.status === 404 || err.status === 409 || err.error?.message?.includes('already exist')) {
          this.successMessage = null;
          this.errorMessage = 'Cannot Create: Location already exists!';
          setTimeout(() => this.errorMessage = null, 5000);
        }
      }
    });
  });
}


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
