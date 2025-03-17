def is_point_in_polygon(lat, lon, polygon):
    num = len(polygon)
    j = num - 1
    inside = False

    for i in range(num):
        lat_i, lon_i = polygon[i]
        lat_j, lon_j = polygon[j]

        if ((lon_i > lon) != (lon_j > lon)) and \
                (lat < (lat_j - lat_i) * (lon - lon_i) / (lon_j - lon_i + 1e-10) + lat_i):
            inside = not inside
        j = i

    return inside




# from shapely.geometry import Point, Polygon

# polygon = Polygon(OFFICE_POLYGON)
# point = Point(lat, lon)

# if not polygon.contains(point):
#     raise HTTPException(status_code=403, detail="Out of area")
