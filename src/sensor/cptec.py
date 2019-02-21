"""
Support for CPTEC/INPE  weather service.
For more details about this platform, please refer to the documentation at
https://github.com/tonyldo/home-automation-project
"""
import asyncio
import logging

import aiohttp
import async_timeout
import voluptuous as vol

from random import randrange

import homeassistant.helpers.config_validation as cv
from homeassistant.components.sensor import PLATFORM_SCHEMA
from homeassistant.const import (
    CONF_LATITUDE, CONF_LONGITUDE, CONF_MONITORED_CONDITIONS,
    ATTR_ATTRIBUTION, CONF_NAME)
from homeassistant.helpers.aiohttp_client import async_get_clientsession
from homeassistant.helpers.entity import Entity
from homeassistant.helpers.event import (async_track_utc_time_change,
                                         async_call_later)
from homeassistant.util import dt as dt_util
from homeassistant.util import location
from homeassistant.helpers import sun

from homeassistant.components.sensor import current

_LOGGER = logging.getLogger(__name__)

ATTR_LAST_UPDATE = 'last_update'
ATTR_STATION_NAME = 'station_id'

CONF_ATTRIBUTION = "Data provider: http://servicos.cptec.inpe.br/XML/"

SENSOR_TYPES = {
    'pressure': ['Pressure', 'mbar'],
    'temperature': ['Temperature', '°C'],
    'weather': ['Weather',None],
    'weather_desc': ['Weather desc',None],
    'humidity': ['Relative Humidity', '%'],
    'wind_dir': ['Wind Direction','º'],
    'wind_speed': ['Wind Speed','km/h'],
    'visibility':['Visibility','m']
}

CONF_STATION = 'station'

DEFAULT_STATION = ''
DEFAULT_NAME = 'CPTEC'

PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Optional(CONF_STATION, default=DEFAULT_STATION): cv.string,
    vol.Optional(CONF_LATITUDE): cv.latitude,
    vol.Optional(CONF_LONGITUDE): cv.longitude,
    vol.Optional(CONF_MONITORED_CONDITIONS, default=['weather']):
        vol.All(cv.ensure_list, vol.Length(min=1), [vol.In(SENSOR_TYPES)]),
    vol.Optional(CONF_NAME, default=DEFAULT_NAME): cv.string,
})


async def async_setup_platform(hass, config, async_add_entities,
                               discovery_info=None):
    """Set up the CPTEC sensor."""
    station = None if config.get(CONF_STATION)=='' else config.get(CONF_STATION)
    latitude = config.get(CONF_LATITUDE, hass.config.latitude)
    longitude = config.get(CONF_LONGITUDE, hass.config.longitude)
    name = config.get(CONF_NAME)

    if None in (latitude, longitude) and  station is None:
        _LOGGER.error("Latitude or longitude or station not set in Home Assistant config")
        return False

    coordinates = (latitude,longitude)

    dev = []
    for sensor_type in config[CONF_MONITORED_CONDITIONS]:
        dev.append(CPTECSensor(name, sensor_type))
    async_add_entities(dev)

    websession = async_get_clientsession(hass)

    data = current.BrazilianCurrentWeather(station_id=station,coordinate=coordinates,distance_func=location.vincenty,async_session=websession)

    CPTEC_control = CPTECControlData(hass,data, dev)
    async_track_utc_time_change(hass, CPTEC_control.updating_devices,
                                minute=31, second=0)
    await CPTEC_control.fetching_data()

class CPTECSensor(Entity):
    """Representation of an CPTEC sensor."""

    def __init__(self, name, sensor_type):
        """Initialize the sensor."""
        self.client_name = name
        self._name = SENSOR_TYPES[sensor_type][0]
        self.type = sensor_type
        self._state = None
        self._unit_of_measurement = SENSOR_TYPES[self.type][1]
        self.url_icon= None
        self.station_id= None
        self.last_updated = None

    @property
    def name(self):
        """Return the name of the sensor."""
        return '{}'.format(self._name)

    @property
    def state(self):
        """Return the state of the device."""
        return self._state

    @property
    def should_poll(self):
        """No polling needed."""
        return False

    @property
    def entity_picture(self):
        """Weather symbol if type is symbol."""
        if self.type != 'weather':
            return None
        return self.url_icon

    @property
    def device_state_attributes(self):
        """Return the state attributes."""
        return {
            ATTR_ATTRIBUTION: CONF_ATTRIBUTION,
            ATTR_LAST_UPDATE: self.last_updated,
            ATTR_STATION_NAME: self.station_id,
        }

    @property
    def unit_of_measurement(self):
        """Return the unit of measurement of this entity, if any."""
        return self._unit_of_measurement


class CPTECControlData:
    """Get the latest data and updates the states."""

    def __init__(self, hass, data, devices):
        """Initialize the data object."""
        self.devices = devices
        self.data = data
        self.hass = hass

    async def fetching_data(self, *_):
        """Get the latest data from CPTEC"""

        def try_again(err: str):
            """Retry in 15 to 20 minutes."""
            minutes = 1
            _LOGGER.error("Retrying in %i minutes: %s", minutes, err)
            async_call_later(self.hass, minutes*60, self.fetching_data)
        try:
            with async_timeout.timeout(10, loop=self.hass.loop):
                await self.data.async_update_current() 

        except (Exception) as err:
            try_again(err)
            return

        await self.updating_devices()
        async_call_later(self.hass, 60*60, self.fetching_data)

    async def updating_devices(self, *_):
        """Find the current data from self.data."""
        if not self.data._conditions:
            return
        # Update all devices
        tasks = []
        for dev in self.devices:
            dev.station_id = self.data.station_id
            dev.last_updated = self.data.get_reading('last_time_updated')  
            new_state = self.data.get_reading(dev.type)
            if new_state != dev._state:
               if dev.type == 'weather':
                  with async_timeout.timeout(10, loop=self.hass.loop):
                     dev.url_icon = await self.data.async_get_formated_icon_URL(_isNight= not sun.is_up(self.hass))
                  if dev.url_icon is None:
                     _LOGGER.error("ERROR when get url icon: %s", dev.url_icon)
               dev._state = new_state
               tasks.append(dev.async_update_ha_state())

        if tasks:
            await asyncio.wait(tasks, loop=self.hass.loop)
