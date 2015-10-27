echo  "== PUT /orders/1 ==============="
curl -i -X PUT -H "Accepts: application/json" -H "Content-Type: application/json" -d '{"order": {"id":1, "title":"Artificial organz", "status_id":2}}' http://localhost:3000/orders/1
echo ""
echo  "== GET /orders/1 ==============="
curl -i -X GET -H "Accepts: application/json" http://localhost:3000/orders/1
echo ""
