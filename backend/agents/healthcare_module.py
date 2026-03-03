"""
Healthcare Locator Module
Integration with Overpass API (OpenStreetMap) to find nearby gynecologists.
Free, no API key required.
"""
import httpx


class HealthcareModule:
    """
    Queries the Overpass API (OpenStreetMap) for nearby
    gynecologists / women's health clinics.
    No API key required — fully open data.
    """

    OVERPASS_URL = "https://overpass-api.de/api/interpreter"

    def find_nearby(self, latitude: float, longitude: float, radius: int = 5000) -> dict:
        """
        Find nearby gynecologists using OpenStreetMap Overpass API.

        Args:
            latitude: User's latitude.
            longitude: User's longitude.
            radius: Search radius in meters.

        Returns:
            {
                "locations": [
                    {
                        "name": str,
                        "address": str,
                        "latitude": float,
                        "longitude": float,
                        "phone": str | None,
                        "osm_id": str
                    }
                ]
            }
        """
        # Overpass QL query: find nodes/ways tagged as gynecologist or
        # healthcare=doctor with healthcare:speciality=gynaecology
        query = f"""
        [out:json][timeout:15];
        (
          node["healthcare"="doctor"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{latitude},{longitude});
          node["amenity"="doctors"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{latitude},{longitude});
          node["amenity"="clinic"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{latitude},{longitude});
          node["amenity"="hospital"](around:{radius},{latitude},{longitude});
          way["healthcare"="doctor"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{latitude},{longitude});
          way["amenity"="hospital"](around:{radius},{latitude},{longitude});
        );
        out center body;
        """

        try:
            response = httpx.post(
                self.OVERPASS_URL,
                data={"data": query},
                timeout=20.0,
            )
            data = response.json()

            locations = []
            for element in data.get("elements", []):
                tags = element.get("tags", {})
                name = tags.get("name", "Unnamed Healthcare Facility")

                # Get coordinates (nodes have lat/lon directly, ways use center)
                lat = element.get("lat") or element.get("center", {}).get("lat", 0.0)
                lon = element.get("lon") or element.get("center", {}).get("lon", 0.0)

                # Build address from available tags
                addr_parts = []
                if tags.get("addr:street"):
                    house = tags.get("addr:housenumber", "")
                    addr_parts.append(f"{house} {tags['addr:street']}".strip())
                if tags.get("addr:city"):
                    addr_parts.append(tags["addr:city"])
                if tags.get("addr:postcode"):
                    addr_parts.append(tags["addr:postcode"])
                address = ", ".join(addr_parts) if addr_parts else "Address not available"

                locations.append({
                    "name": name,
                    "address": address,
                    "latitude": float(lat),
                    "longitude": float(lon),
                    "phone": tags.get("phone") or tags.get("contact:phone"),
                    "osm_id": str(element.get("id", "")),
                })

            return {"locations": locations}

        except httpx.RequestError as e:
            return {"locations": [], "error": str(e)}
