
# {
#   "sharpen": {
#     "radius": 100,
#     "x1": 0.1
#   },
# }
/image?url=https://[....].png&sharpen[x1]=0.1&sharpen[radius]=100

# {
#   "resize": [
#     0.3
#   ]
# }
/image?url=https://[....].png&resize[]=0.3
/image?url=https://[....].png&resize[]=2

# {
#   "shrink": [
#     2
#   ]
# }
/image?url=https://[....].png&shrinkh[]=2




# 1 - login using admin credentials
curl -X POST -H "Content-Type: application/json" \
  -d '{ "user": {
      "email":"admin@admin.admin","password":"adminadmin"
    }
  }' \
  http://localhost:4000/users/sign_in -v

# responsed header
"token": "eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs",
{
  "id": 1,
  "email": "admin@localhost.test",
  "username": "admin",
  "first_name": "",
  "last_name": "",
  "avatar": null,
  "role": "admin",
  "confirmed_at": null,
  "created_at": "2025-01-27T11:18:24.422Z",
  "updated_at": "2025-01-28T09:59:51.845Z"
}

# 2 - process image
/image?url=https://[....].png&f=jpg&resize%5Bwidth%5D=300

curl "http://localhost:4000/image?url=https://[....].png&format=jpg&resize%5Bwidth%5D=300" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -i

/image?url=https://[....].png&f=jpg&bg=red&q=100&rotate[]=120&rotate[][background]=lime
curl "http://localhost:4000/image?url=https://[....].png" \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.eyJzdWIiOiIxIiwic2NwIjoidXNlciIsImF1ZCI6bnVsbCwiaWF0IjoxNzM4NDgxOTgyLCJleHAiOjE3Mzg0ODU1ODIsImp0aSI6ImVhNTljYmQ2LTI2N2QtNGUzNy1hYzZkLTJhYzNiMWRlMmI5ZiJ9.F6tKU3JE8wAlDq2SR52GW7cZlSnEyq_-E1PiCLyfefs" \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{
    "format": "jpg",
    "bg": "red",
    "q": 100,
    "rotate": [
      120,
      {
        "background": "lime"
      }
    ]
  }' -v

# browser fetch
fetch("/image/?url=https://[....].png&format=jpg&sharpen%5Bsigma%5D=0.5&sharpen%5Bx1%5D=0.8")

/image?url=https://[....].png&f=jpg&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&rotate%5B%5D=120&rotate%5B%5D%5Bbackground%5D=%23ff0000
fetch("/image?url=https://[....].png&toFormat=jpg&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&rotate%5B0%5D=120&rotate%5B1%5D%5Bbackground%5D=%23ff0000")

# get request
fetch("/image?url=https://[....].png&toFormat=jpg&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&rotate%5B0%5D=120")
# post request
fetch("/image", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    url: "https://[....].png",
    toFormat: "jpg",
    resize: {
      width: 300,
      height: 300,
    },
    rotate: 120,
  }),
})

fetch("/image?url=https://[....].png&toFormat=jpg&resize%5Bwidth%5D=300&resize%5Bheight%5D=300")

# quality 100 percent
# get request
fetch("/image?url=https://[....].png&toFormat%5B0%5D=jpeg&toFormat%5B1%5D%5Bquality%5D=100&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&bg=orange")
# post request
fetch("/image?url=https://[....].png", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    toFormat: [
      {
        format: "jpeg",
        quality: 100,
      },
    ],
    resize: {
      width: 300,
      height: 300,
    },
    bg: "orange",
  }),
})

# quality 80 percent
# get request
fetch("/image?url=https://[....].png&format=jpeg&resize%5Bwidth%5D=300&resize%5Bheight%5D=300&bg=orange")
# post request
fetch("/image?url=https://[....].png", {
  method: "POST",
  headers: {
    "Content-Type": "application/json",
  },
  body: JSON.stringify({
    format: "jpeg",
    resize: {
      width: 300,
      height: 300,
    },
    bg: "orange",
  }),
})
