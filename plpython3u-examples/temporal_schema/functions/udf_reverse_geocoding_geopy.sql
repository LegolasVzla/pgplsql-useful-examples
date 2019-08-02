CREATE OR REPLACE FUNCTION public.udf_reverse_geocoding_geopy(param_latitude character varying, param_longitude character varying)
    RETURNS text
    LANGUAGE 'plpython3u'
    COST 100.0
    VOLATILE
AS $function$

# To test:
# select public.udf_reverse_geocoding_geopy('10.4823307','-66.861713');
    import site
    site.addsitedir('/your_virtualenv_path/lib/pythonX.Y/site-packages')
    from geopy.geocoders import Nominatim
    json_resulting = {}
    geolocator = Nominatim(user_agent="specify_your_app_name_here")
    location = geolocator.reverse(str(param_latitude)+", "+str(param_longitude))

    return location

$function$;

ALTER FUNCTION public.udf_reverse_geocoding_geopy(character varying,character varying)
    OWNER TO postgres;
