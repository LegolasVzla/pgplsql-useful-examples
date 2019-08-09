CREATE OR REPLACE FUNCTION public.udf_reverse_geocoding_geopy(param_latitude character varying, param_longitude character varying
    )
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
    from geopy.exc import GeocoderTimedOut
    json_resulting = {}
    geolocator = Nominatim(user_agent="My_Django_Google_Map_App",timeout=3)
    try:
        location = geolocator.reverse(param_latitude+", "+param_longitude)
        #location = geolocator.reverse("10.4823307, -66.861713")
        if(location):
            try:
                json_resulting['country_name']=location.raw['address']['country']
                json_resulting['country_code']=location.raw['address']['country_code'].upper()
            except Exception as e:
                json_resulting["country_name"]="undefined"
                json_resulting["country_code"]="undefined"
            try:
                json_resulting['state_name']=location.raw['address']['state']
            except Exception as e:
                json_resulting["state_name"]="undefined"
            try:
                json_resulting['city_name']=location.raw['address']['city']
            except Exception as e:
                json_resulting["city_name"]="undefined"
            try:
                json_resulting['postal_code']=location.raw['address']['postcode']
            except Exception as e:
                json_resulting["postal_code"]="undefined"
            try:
                json_resulting['full_address']=location.raw['display_name']
            except Exception as e:
                json_resulting['full_address']="undefined"
    except (GeocoderTimedOut) as e:    
        print("Error: geocode failed on input %s with message %s"%(param_latitude," ",param_longitude, e.message))
        for i,j in json_resulting.items():
            json_resulting[i] = "undefined"

    return json_resulting

$function$;

ALTER FUNCTION public.udf_reverse_geocoding_geopy(character varying,character varying)
    OWNER TO postgres;
