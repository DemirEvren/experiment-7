export interface Todo {
  title: string;
  label: string;
  completed: boolean;
  createdAt: Date;
  _id?: string;
  locationId?: string;   // ✅ camelCase for frontend
  locationName?: string; // ✅ for showing name in UI
}
