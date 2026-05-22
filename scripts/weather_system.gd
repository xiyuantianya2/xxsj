extends Node

# 天气系统
class_name WeatherSystem

signal weather_changed

enum WeatherType {
	SUNNY,
	CLOUDY,
	RAINY,
	THUNDERSTORM,
	FOGGY,
	SNOWY
}

var current_weather = WeatherType.SUNNY
var weather_timer: Timer
var weather_duration = 60.0  # 每种天气持续时间（秒）

func _ready():
	weather_timer = Timer.new()
	weather_timer.wait_time = weather_duration
	weather_timer.timeout.connect(change_weather)
	add_child(weather_timer)
	weather_timer.start()

func change_weather():
	var weathers = [WeatherType.SUNNY, WeatherType.CLOUDY, WeatherType.RAINY, WeatherType.FOGGY]
	current_weather = weathers[randi() % weathers.size()]
	emit_signal("weather_changed", current_weather)
	weather_timer.start()

func get_weather_name() -> String:
	match current_weather:
		WeatherType.SUNNY: return "晴朗"
		WeatherType.CLOUDY: return "多云"
		WeatherType.RAINY: return "雨天"
		WeatherType.THUNDERSTORM: return "雷暴"
		WeatherType.FOGGY: return "大雾"
		WeatherType.SNOWY: return "雪天"
		_: return "未知"

func get_weather_effect() -> Dictionary:
	match current_weather:
		WeatherType.RAINY:
			return {"cultivation_bonus": 0.1, "encounter_rate": 0.8}
		WeatherType.THUNDERSTORM:
			return {"cultivation_bonus": 0.2, "encounter_rate": 1.2}
		WeatherType.FOGGY:
			return {"visibility": 0.5, "encounter_rate": 0.6}
		_:
			return {}
