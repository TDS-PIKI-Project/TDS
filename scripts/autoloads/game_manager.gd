extends Node

var auth_token: String = ""
var username: String = ""

func save_token(token: String):
	auth_token = token

func is_logged_in() -> bool:
	return auth_token != ""
