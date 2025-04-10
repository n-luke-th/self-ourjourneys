def get_mock_authorizer(uid="test-user", email="user@example.com"):
    return {
        "requestContext": {
            "authorizer": {
                "uid": uid,
                "email": email
            }
        }
    }
