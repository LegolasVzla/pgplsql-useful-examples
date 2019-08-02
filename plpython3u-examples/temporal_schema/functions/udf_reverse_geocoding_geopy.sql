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
    if(location):
        json_resulting['country_name']=location.raw['address']['country']
        json_resulting['state_name']=location.raw['address']['state']
        json_resulting['city_name']=location.raw['address']['county']
        json_resulting['postal_code']=location.raw['address']['postcode']
        json_resulting['road']=location.raw['address']['postcode']
        json_resulting['full_address']=location.address
    else:
        json_resulting['country_name']="undefined"
        json_resulting['state_name']="undefined"
        json_resulting['city_name']="undefined"
        json_resulting['postal_code']="undefined"
        json_resulting['road']="undefined"
        json_resulting['full_address']="undefined"
    return location

$function$;

ALTER FUNCTION public.udf_reverse_geocoding_geopy(character varying,character varying)
    OWNER TO postgres;
