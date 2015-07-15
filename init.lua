
--funkcja która zwraca zawartość pliku
sendFileContents = function(conn, filename)
	if file.open(filename, "r") then --jeżeli istnieje plik o danej nazwie to go otwórz
		--conn:send(responseHeader("200 OK","text/html"));
		repeat
			local line=file.readline() --odczytaj linijka po linijce plik
			if line then 
				conn:send(line); --wysyła zawartość linijki do klienta
			end 
		until not line 
		file.close(); --zamyka plik
	else --jeżeli plik nie istnieje
		conn:send(responseHeader("404 Not Found","text/html")); --wysyłamy nagłówek HTTP 404 - czyli nie znaleziono pliku
		conn:send("Page not found");
			end
end

responseHeader = function(code, type) --określamy nagłówek HTTP identyfikujący nasz serwer
	return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: nunu-Luaweb\r\nContent-Type: " .. type .. "\r\n\r\n"; 
end

--funkcja inicjująca
httpserver = function ()
	gpio.mode(3, gpio.OUTPUT); --ustaw pin GPIO0 jako wyjście
	gpio.mode(4, gpio.OUTPUT); --ustaw pin GPIO2 jako wyjście
	gpio.write(3,gpio.LOW); --ustaw stan niski na pinie GPIO0
	gpio.write(4,gpio.LOW); --ustaw stan niski na pinie GPIO2
	gpio2_state=0; --zmienna poczatkowa stanu pinu GPIO2
	gpio0_state=0; --zmienna poczatkowa stanu pinu GPIO0
	licznik=0; --zmienna licznika operacji
	wifi.setmode(wifi.SOFTAP);
	wifi.ap.config({ssid="ESP8266",pwd="politechnika"});
	srv=net.createServer(net.TCP) --tworzymy serwer HTTP
    srv:listen(80,function(conn) --serwer nasłuchuje na porcie 80
      conn:on("receive",function(conn,request) --w przypadku zapytania HTTP
		conn:send(responseHeader("200 OK","text/html")); --wysyłamy nagłówek HTTP OK
		if string.find(request,"gpio=0") then --jeżeli w adresie URL zapytania jest tekst "gpio=0"
			licznik=licznik+1; --dodaj do licznika operacji
			if gpio0_state==0 then --jeżeli zmienna stanu pinu GPIO0 jest równa 0
				gpio0_state=1; --ustaw zmienną stanu pinu GPIO0 na 1
				gpio.write(3,gpio.HIGH); --ustaw stan wysoki na pinie GPIO0
			else --w przeciwnym wypadku
				gpio0_state=0; --ustaw zmienną stanu pinu GPIO0 na 0
				gpio.write(3,gpio.LOW); --ustaw stan niski na pinie GPIO0
			end
		elseif string.find(request,"gpio=2") then
			licznik=licznik+1; --dodaj do licznika operacji
			if gpio2_state==0 then
				gpio2_state=1;
				gpio.write(4,gpio.HIGH);
			else
				gpio2_state=0;
				gpio.write(4,gpio.LOW);
			end
		else
			if gpio0_state==1 then
				preset0_on="";
			end
			if gpio0_state==0 then
				preset0_on="checked=\"checked\"";
			end
			if gpio2_state==1 then
				preset2_on="";
			end
			if gpio2_state==0 then
				preset2_on="checked=\"checked\"";
			end
			sendFileContents(conn,"header.htm"); --wyświetl nagłówek panelu kontrolnego
			--wyświetl tablicę przełączników
			conn:send("<div><input type=\"checkbox\" id=\"checkbox0\" name=\"checkbox0\" class=\"switch\" onclick=\"loadXMLDoc(0)\" "..preset0_on.." />");
			conn:send("<label for=\"checkbox0\">GPIO 0</label></div>");
			conn:send("<div><input type=\"checkbox\" id=\"checkbox2\" name=\"checkbox2\" class=\"switch\" onclick=\"loadXMLDoc(2)\" "..preset2_on.." />");
			conn:send("<label for=\"checkbox2\">GPIO 2</label></div>");
			conn:send("<div><h2>Licznik operacji: "..licznik.."</h2></div>"); --wyświetl licznik operacji
			conn:send("</div>");
		end
		print(request);
      end) 
      conn:on("sent",function(conn) 
		conn:close(); 
		conn = nil;	

	  end)
    end)
end

httpserver()
