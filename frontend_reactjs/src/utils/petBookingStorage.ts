// Temporary storage for pet-booking associations
// This is a workaround since the backend doesn't include pet_id in booking responses
interface PetBookingAssociation {
  bookingId: number;
  petId: number;
  petName: string;
  petSpecies: string;
  timestamp: number;
}

const STORAGE_KEY = 'pet_booking_associations';
const MAX_STORAGE_AGE = 30 * 24 * 60 * 60 * 1000; // 30 days in milliseconds

class PetBookingStorage {
  private getStoredData(): PetBookingAssociation[] {
    try {
      const data = localStorage.getItem(STORAGE_KEY);
      if (!data) return [];
      
      const associations: PetBookingAssociation[] = JSON.parse(data);
      
      // Filter out old entries
      const now = Date.now();
      const validAssociations = associations.filter(
        assoc => now - assoc.timestamp < MAX_STORAGE_AGE
      );
      
      // Update storage if we filtered out old entries
      if (validAssociations.length !== associations.length) {
        this.saveStoredData(validAssociations);
      }
      
      return validAssociations;
    } catch (error) {
      console.error('Error reading pet booking storage:', error);
      return [];
    }
  }

  private saveStoredData(data: PetBookingAssociation[]): void {
    try {
      localStorage.setItem(STORAGE_KEY, JSON.stringify(data));
    } catch (error) {
      console.error('Error saving pet booking storage:', error);
    }
  }

  // Save pet association when creating/editing a booking
  savePetBookingAssociation(bookingId: number, petId: number, petName: string, petSpecies: string): void {
    if (!bookingId || !petId) return;
    
    const associations = this.getStoredData();
    
    // Remove existing association for this booking
    const filteredAssociations = associations.filter(assoc => assoc.bookingId !== bookingId);
    
    // Add new association
    filteredAssociations.push({
      bookingId,
      petId,
      petName,
      petSpecies,
      timestamp: Date.now(),
    });
    
    this.saveStoredData(filteredAssociations);
  }

  // Get pet info for a booking
  getPetForBooking(bookingId: number): { name: string; species: string } | null {
    const associations = this.getStoredData();
    const association = associations.find(assoc => assoc.bookingId === bookingId);
    
    if (association) {
      return {
        name: association.petName,
        species: association.petSpecies,
      };
    }
    
    return null;
  }

  // Remove association when booking is deleted
  removePetBookingAssociation(bookingId: number): void {
    const associations = this.getStoredData();
    const filteredAssociations = associations.filter(assoc => assoc.bookingId !== bookingId);
    this.saveStoredData(filteredAssociations);
  }

  // Clear all associations (for cleanup/debugging)
  clearAllAssociations(): void {
    localStorage.removeItem(STORAGE_KEY);
  }

  // Get all associations (for debugging)
  getAllAssociations(): PetBookingAssociation[] {
    return this.getStoredData();
  }
}

export const petBookingStorage = new PetBookingStorage();
export type { PetBookingAssociation }; 