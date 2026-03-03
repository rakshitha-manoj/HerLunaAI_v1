"""
HerLuna Healthcare Locator Route
GET endpoint using Overpass API (OpenStreetMap).
Rate limited (429) — Overpass API has rate limits.
"""
from fastapi import APIRouter, HTTPException, Query, status
import httpx

from schemas import HealthcareResponse, HealthcareLocation

router = APIRouter()

OVERPASS_URL = "https://overpass-api.de/api/interpreter"


@router.get(
    "/nearby",
    response_model=HealthcareResponse,
    responses={
        200: {"description": "Healthcare locations found"},
        429: {"description": "Rate limit exceeded (Overpass API constraint)"},
        503: {"description": "Overpass API unavailable"},
    },
)
async def find_nearby_healthcare(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    radius: int = Query(5000, ge=500, le=50000, description="Search radius in meters"),
):
    """
    Find nearby gynecologists using Overpass API (OpenStreetMap).
    GET /healthcare/nearby?lat=12.97&lng=77.59&radius=5000
    Rate limited to prevent Overpass API abuse.
    """
    query = f"""
    [out:json][timeout:15];
    (
      node["healthcare"="doctor"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{lat},{lng});
      node["amenity"="doctors"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{lat},{lng});
      node["amenity"="clinic"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{lat},{lng});
      node["amenity"="hospital"](around:{radius},{lat},{lng});
      way["healthcare"="doctor"]["healthcare:speciality"~"gynaecology|gynecology"](around:{radius},{lat},{lng});
      way["amenity"="hospital"](around:{radius},{lat},{lng});
    );
    out center body;
    """

    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                OVERPASS_URL,
                data={"data": query},
                timeout=20.0,
            )
            data = response.json()

        locations = []
        for element in data.get("elements", []):
            tags = element.get("tags", {})
            name = tags.get("name", "Unnamed Healthcare Facility")

            elem_lat = element.get("lat") or element.get("center", {}).get("lat", 0.0)
            elem_lng = element.get("lon") or element.get("center", {}).get("lon", 0.0)

            addr_parts = []
            if tags.get("addr:street"):
                house = tags.get("addr:housenumber", "")
                addr_parts.append(f"{house} {tags['addr:street']}".strip())
            if tags.get("addr:city"):
                addr_parts.append(tags["addr:city"])
            if tags.get("addr:postcode"):
                addr_parts.append(tags["addr:postcode"])
            address = ", ".join(addr_parts) if addr_parts else "Address not available"

            locations.append(
                HealthcareLocation(
                    name=name,
                    address=address,
                    lat=float(elem_lat),
                    lng=float(elem_lng),
                    phone=tags.get("phone") or tags.get("contact:phone"),
                )
            )

        return HealthcareResponse(locations=locations)

    except httpx.RequestError as e:
        raise HTTPException(
            status_code=503, detail=f"Overpass API error: {str(e)}"
        )
