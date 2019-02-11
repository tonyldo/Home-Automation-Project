"""
Support for Brazilian CPTEC/INPE weather service.
For more details about this platform, please refer to the documentation at
https://github.com/tonyldo/BrazilianForecastIO
"""
import datetime
import logging

import requests
import voluptuous as vol

import homeassistant.helpers.config_validation as cv
from homeassistant.components.sensor import PLATFORM_SCHEMA
from homeassistant.const import (
    CONF_MONITORED_CONDITIONS, TEMP_CELSIUS, CONF_NAME, ATTR_ATTRIBUTION,
    CONF_LATITUDE, CONF_LONGITUDE)
from homeassistant.helpers.entity import Entity
from homeassistant.util import Throttle

_RESOURCE = 'http://servicos.cptec.inpe.br/XML/estacao/%s/condicoesAtuais.xml'
_LOGGER = logging.getLogger(__name__)

CONF_ATTRIBUTION = "Data provided by CPTEC/INPE"
CONF_STATION = 'station'

MIN_TIME_BETWEEN_UPDATES = datetime.timedelta(seconds=30)

SENSOR_TYPES = {
    'pressure': ['Pressure', 'mbar'],
    'temperature': ['Temperature', TEMP_CELSIUS],
    'weather': ['Weather',None],
    'weather_desc': ['Weather desc',None],
    'humidity': ['Relative Humidity', '%'],
    'wind_dir': ['Wind Direction','º'],
    'wind_speed': ['Wind Speed','km/h'],
    'visibility':['Visibility','m']
}

PLATFORM_SCHEMA = PLATFORM_SCHEMA.extend({
    vol.Optional(CONF_NAME): cv.string,
    vol.Optional(CONF_STATION): cv.string,
    vol.Required(CONF_MONITORED_CONDITIONS, default=['weather'])):
        vol.All(cv.ensure_list, [vol.In(SENSOR_TYPES)]),
})


def setup_platform(hass, config, add_entities, discovery_info=None):
    """Set up the CPTEC sensor."""
    station = config.get(CONF_STATION)
    CPTEC_data = None

    if station is not None:
       CPTEC_data = CPTECCurrentData(station)
    else:
       from homeassistant.util.location import vincenty
       CPTEC_data = CPTECCurrentData(coordinate = (config.get(CONF_LATITUDE), config.get(CONF_LONGITUDE)),distanceFunc = vincenty)

    if CPTEC_data is None:
       _LOGGER.error("Error creating CPTEC data object: %s", err)
       return

    try:
        CPTEC_data.update()
    except ValueError as err:
        _LOGGER.error("Received error from CPTEC: %s", err)
        return

    add_entities([CPTECCurrentSensor(CPTEC_data, variable, config.get(CONF_NAME))
                  for variable in config[CONF_MONITORED_CONDITIONS]])


class CPTECCurrentSensor(Entity):
    """Implementation of a BOM current sensor."""

    def __init__(self, cptec_data, condition, stationname):
        """Initialize the sensor."""
        self.cptec_data = cptec_data
        self._condition = condition
        self.stationname = stationname

    @property
    def name(self):
        """Return the name of the sensor."""
        if self.stationname is None:
            return 'CPTEC {}'.format(SENSOR_TYPES[self._condition][0])

        return 'CPTEC {} {}'.format(
            self.stationname, SENSOR_TYPES[self._condition][0])

    @property
    def state(self):
        """Return the state of the sensor."""
        return self.cptec_data.condition_readings(self._condition)

    @property
    def entity_picture(self):
        """Weather symbol if type is symbol."""
        if self.type != 'weather':
            return None
        return self.cptec_data.get_formated_icon_URL(self._condition)

    @property
    def unit_of_measurement(self):
        """Return the units of measurement."""
        return SENSOR_TYPES[self._condition][1]

    def update(self):
        """Update current conditions."""
        self.cptec_data.update()


class CPTECCurrentData:
    """Get data from CPTEC."""

    def __init__(self, station_id=None, coordinate=None, distanceFunc=None, current_data_url=None, current_icon_url=None, session=None ):
        """Initialize the data object."""
        self._data = BrazilianForeCastIO(station_id, coordinate, current_data_url, current_icon_url, distanceFunc)
        self.last_updated = None

    def get_reading(self, condition):
        """Return the value for the given condition."""
        return self._data.condition_readings(condition)

    def should_update(self):
        """Determine whether an update should occur.
        CPTEC provides updated data every full hour like: 10/02/2019 14:00:00 (dd/MM/yyyy hh:mm:ss)"""
        if self.last_updated is None:
            # Never updated before, therefore an update should occur.
            return True

        now = datetime.datetime.now()
        return  now.hour =! self._data.last_updated.hour

    @Throttle(MIN_TIME_BETWEEN_UPDATES)
    def update(self):
        """Get the latest data from CPTEC."""
        if not self.should_update():
            _LOGGER.debug(
                "CPTEC was updated %s minutes ago, Now: %s, LastUpdate: %s",
                (datetime.datetime.now() - self.last_updated),
                datetime.datetime.now(), self.last_updated)
            return

        try:
            self._data.update()
            self.last_updated = self._data.last_update
            return

        except ValueError as err:
            _LOGGER.error("Check CPTEC %s", err.args)
            self._data = None
            raise
