
INSERT INTO FakePeople (FirstName, Surname, Email, Sex)
SELECT DISTINCT OtherFirstName AS Firstname, FP.Surname, (OtherFirstName + '.' + FP.Surname + '@iam_fake_email.com') AS Email, FP.Sex
FROM dbo.FakePeople FP
, (
SELECT 'Quinton' AS OtherFirstName
UNION SELECT 'Jayden'
UNION SELECT 'Aydin'
UNION SELECT 'Peyton'
UNION SELECT 'Elias'
UNION SELECT 'Lennon'
UNION SELECT 'Valentino'
UNION SELECT 'Greyson'
UNION SELECT 'Jaxon'
UNION SELECT 'Leonel'
UNION SELECT 'Reece'
UNION SELECT 'Seth'
UNION SELECT 'Quinten'
UNION SELECT 'Brogan'
UNION SELECT 'Trenton'
UNION SELECT 'Hassan'
UNION SELECT 'Karter'
UNION SELECT 'Cristian'
UNION SELECT 'Lee'
UNION SELECT 'Hayden'
UNION SELECT 'Blake'
UNION SELECT 'Amir'
UNION SELECT 'Nickolas'
UNION SELECT 'Collin'
UNION SELECT 'Abdiel'
UNION SELECT 'Billy'
UNION SELECT 'Antonio'
UNION SELECT 'Philip'
UNION SELECT 'Yusuf'
UNION SELECT 'Drew'
UNION SELECT 'Rylan'
UNION SELECT 'Nathanial'
UNION SELECT 'Gideon'
UNION SELECT 'Kaden'
UNION SELECT 'Kolton'
UNION SELECT 'Aditya'
UNION SELECT 'Emery'
UNION SELECT 'Pierre'
UNION SELECT 'Franco'
UNION SELECT 'Levi'
UNION SELECT 'Ali'
UNION SELECT 'Denzel'
UNION SELECT 'Kymani'
UNION SELECT 'Chance'
UNION SELECT 'Winston'
UNION SELECT 'Eddie'
UNION SELECT 'Ronin'
UNION SELECT 'Luca'
UNION SELECT 'Joey'
UNION SELECT 'Darryl'
UNION SELECT 'Mekhi'
UNION SELECT 'Case'
UNION SELECT 'Parker'
UNION SELECT 'Blaze'
UNION SELECT 'Evan'
UNION SELECT 'Hunter'
UNION SELECT 'Uriel'
UNION SELECT 'Wyatt'
UNION SELECT 'Aldo'
UNION SELECT 'Adolfo'
UNION SELECT 'Isaiah'
UNION SELECT 'Davis'
UNION SELECT 'King'
UNION SELECT 'Gerald'
UNION SELECT 'Ryker'
UNION SELECT 'Nash'
UNION SELECT 'Grady'
UNION SELECT 'Easton'
UNION SELECT 'Gilbert'
UNION SELECT 'Melvin'
UNION SELECT 'Lukas'
UNION SELECT 'Bryce'
UNION SELECT 'Elvis'
UNION SELECT 'Jake'
UNION SELECT 'Quincy'
UNION SELECT 'Fisher'
UNION SELECT 'Dwayne'
UNION SELECT 'Thomas'
UNION SELECT 'Jordan'
UNION SELECT 'Gaige'
UNION SELECT 'Lawrence'
UNION SELECT 'Colby'
UNION SELECT 'Donavan'
UNION SELECT 'Gordon'
UNION SELECT 'Marshall'
UNION SELECT 'Kellen'
UNION SELECT 'Jabari'
UNION SELECT 'Andreas'
UNION SELECT 'Lucian'
UNION SELECT 'Kristian'
UNION SELECT 'Manuel'
UNION SELECT 'Enzo'
UNION SELECT 'Ariel'
UNION SELECT 'Brice'
UNION SELECT 'Kristopher'
UNION SELECT 'Hector'
UNION SELECT 'Micah'
UNION SELECT 'Amare'
UNION SELECT 'Carsen'
UNION SELECT 'Luis'
UNION SELECT 'Ronan'
UNION SELECT 'Alfred'
UNION SELECT 'Immanuel'
UNION SELECT 'Odin'
UNION SELECT 'Jaylon'
UNION SELECT 'Shamar'
UNION SELECT 'Oscar'
UNION SELECT 'Ibrahim'
UNION SELECT 'David'
UNION SELECT 'Atticus'
UNION SELECT 'Judah'
UNION SELECT 'Darrell'
UNION SELECT 'Carmelo'
UNION SELECT 'Chace'
UNION SELECT 'Luciano'
UNION SELECT 'Ulises'
UNION SELECT 'Alan'
UNION SELECT 'Jan'
UNION SELECT 'Jonah'
UNION SELECT 'Garrett'
UNION SELECT 'Jonathan'
UNION SELECT 'Aiden'
UNION SELECT 'Jalen'
UNION SELECT 'Fabian'
UNION SELECT 'Joe'
UNION SELECT 'Sincere'
UNION SELECT 'Emmanuel'
UNION SELECT 'Chaz'
UNION SELECT 'Russell'
UNION SELECT 'Ellis'
UNION SELECT 'Jasper'
UNION SELECT 'Killian'
UNION SELECT 'Abdullah'
UNION SELECT 'Deshawn'
UNION SELECT 'Arnav'
UNION SELECT 'Teagan'
UNION SELECT 'Cristopher'
UNION SELECT 'Samuel'
UNION SELECT 'Donald'
UNION SELECT 'Sebastian'
UNION SELECT 'Kyler'
UNION SELECT 'Kamron'
UNION SELECT 'Terrance'
UNION SELECT 'Jose'
UNION SELECT 'Maximus'
UNION SELECT 'Rhys'
UNION SELECT 'Kieran'
UNION SELECT 'Brayan'
UNION SELECT 'Marcelo'
UNION SELECT 'Cory'
UNION SELECT 'Louis'
UNION SELECT 'Jaydon'
UNION SELECT 'Orion'
UNION SELECT 'Joel'
UNION SELECT 'Armando'
UNION SELECT 'Zachary'
UNION SELECT 'Dennis'
UNION SELECT 'Clinton'
UNION SELECT 'Jackson'
UNION SELECT 'Sidney'
UNION SELECT 'Andres'
UNION SELECT 'Nick'
UNION SELECT 'Lawson'
UNION SELECT 'Christian'
UNION SELECT 'Antwan'
UNION SELECT 'Gauge'
UNION SELECT 'Sam'
UNION SELECT 'Santino'
UNION SELECT 'Trey'
UNION SELECT 'August'
UNION SELECT 'Kylan'
UNION SELECT 'Ruben'
UNION SELECT 'Rayan'
UNION SELECT 'Steven'
UNION SELECT 'Misael'
UNION SELECT 'Ahmed'
UNION SELECT 'Jaime'
UNION SELECT 'Jovani'
UNION SELECT 'Aaden'
UNION SELECT 'Lorenzo'
UNION SELECT 'Jadyn'
UNION SELECT 'Gavyn'
UNION SELECT 'Rigoberto'
UNION SELECT 'Payton'
UNION SELECT 'Quinn'
UNION SELECT 'Rohan'
UNION SELECT 'Tyrell'
UNION SELECT 'Arjun'
UNION SELECT 'Giancarlo'
UNION SELECT 'Kody'
UNION SELECT 'Felipe'
UNION SELECT 'Gerardo'
UNION SELECT 'Darnell'
UNION SELECT 'Carter'
UNION SELECT 'Leon'
UNION SELECT 'Nicholas'
UNION SELECT 'Allen'
UNION SELECT 'Milo'
UNION SELECT 'Davian'
UNION SELECT 'Nikhil'
UNION SELECT 'Fletcher'
UNION SELECT 'Shawn'
UNION SELECT 'Brett'
UNION SELECT 'Dane'
UNION SELECT 'Terry'
UNION SELECT 'Cortez'
UNION SELECT 'Omari'
UNION SELECT 'Camryn'
UNION SELECT 'Casey'
UNION SELECT 'Waylon'
UNION SELECT 'Jace'
UNION SELECT 'Moses'
UNION SELECT 'Emilio'
UNION SELECT 'Duncan'
UNION SELECT 'Clark'
UNION SELECT 'Nasir'
UNION SELECT 'Chandler'
UNION SELECT 'Callum'
UNION SELECT 'Braylon'
UNION SELECT 'Dominick'
UNION SELECT 'Muhammad'
UNION SELECT 'Quintin'
UNION SELECT 'Adan'
UNION SELECT 'Jorden'
UNION SELECT 'Bryan'
UNION SELECT 'Shane'
UNION SELECT 'Nigel'
UNION SELECT 'Alexzander'
UNION SELECT 'Brendon'
UNION SELECT 'Jair'
UNION SELECT 'Tristan'
UNION SELECT 'Tristian'
UNION SELECT 'Larry'
UNION SELECT 'Talan'
UNION SELECT 'Silas'
UNION SELECT 'Paxton'
UNION SELECT 'Yadiel'
UNION SELECT 'Rocco'
UNION SELECT 'Adonis'
UNION SELECT 'Ty'
UNION SELECT 'Jason'
UNION SELECT 'Preston'
UNION SELECT 'Zachariah'
UNION SELECT 'Davion'
UNION SELECT 'Logan'
UNION SELECT 'Isaias'
UNION SELECT 'Reed'
UNION SELECT 'Andy'
UNION SELECT 'Anthony'
UNION SELECT 'Kobe'
UNION SELECT 'Simeon'
UNION SELECT 'Dale'
UNION SELECT 'Ricky'
UNION SELECT 'Jamarcus'
UNION SELECT 'Kole'
UNION SELECT 'Josh'
UNION SELECT 'Bennett'
UNION SELECT 'Todd'
UNION SELECT 'Kamren'
UNION SELECT 'Ean'
UNION SELECT 'Cooper'
UNION SELECT 'Rolando'
UNION SELECT 'Chad'
UNION SELECT 'Danny'
UNION SELECT 'Spencer'
UNION SELECT 'Cristofer'
UNION SELECT 'Justin'
UNION SELECT 'Phillip'
UNION SELECT 'Haiden'
UNION SELECT 'Reid'
UNION SELECT 'Salvador'
UNION SELECT 'Gianni'
UNION SELECT 'Harley'
UNION SELECT 'Abram'
UNION SELECT 'Cruz'
UNION SELECT 'Zavier'
UNION SELECT 'Osvaldo'
UNION SELECT 'Derrick'
UNION SELECT 'Charles'
UNION SELECT 'Theodore'
UNION SELECT 'Coby'
UNION SELECT 'Kevin'
UNION SELECT 'Walter'
UNION SELECT 'Dominik'
UNION SELECT 'Skylar'
UNION SELECT 'Leonardo'
UNION SELECT 'Skyler'
UNION SELECT 'Jon'
UNION SELECT 'Grayson'
UNION SELECT 'Ethen'
UNION SELECT 'Jerome'
UNION SELECT 'Octavio'
UNION SELECT 'Jensen'
UNION SELECT 'Xzavier'
UNION SELECT 'Cedric'
UNION SELECT 'Johan'
UNION SELECT 'Camron'
UNION SELECT 'Byron'
UNION SELECT 'Albert'
UNION SELECT 'Phoenix'
UNION SELECT 'Christopher'
UNION SELECT 'Jacoby'
UNION SELECT 'Braiden'
UNION SELECT 'Humberto'
UNION SELECT 'Izayah'
UNION SELECT 'Frankie'
UNION SELECT 'Eli'
UNION SELECT 'John'
UNION SELECT 'Barrett'
UNION SELECT 'Lane'
UNION SELECT 'Franklin'
UNION SELECT 'Noah'
UNION SELECT 'Tyler'
UNION SELECT 'Hamza'
UNION SELECT 'Toby'
UNION SELECT 'Zion'
UNION SELECT 'Elisha'
UNION SELECT 'Soren'
UNION SELECT 'Jermaine'
UNION SELECT 'Jax'
UNION SELECT 'Cason'
UNION SELECT 'Deacon'
UNION SELECT 'Beckett'
UNION SELECT 'Simon'
UNION SELECT 'Tristen'
UNION SELECT 'Roland'
UNION SELECT 'Mateo'
UNION SELECT 'Elliott'
UNION SELECT 'Alfredo'
UNION SELECT 'Erick'
UNION SELECT 'Emerson'
UNION SELECT 'Wayne'
UNION SELECT 'Augustus'
UNION SELECT 'Eduardo'
UNION SELECT 'Coleman'
UNION SELECT 'Maximo'
UNION SELECT 'Derick'
UNION SELECT 'Weston'
UNION SELECT 'Anton'
UNION SELECT 'Oliver'
UNION SELECT 'Cannon'
UNION SELECT 'Douglas'
UNION SELECT 'Ashton'
UNION SELECT 'Yosef'
UNION SELECT 'Freddy'
UNION SELECT 'Ray'
UNION SELECT 'Gunner'
UNION SELECT 'Jaylan'
UNION SELECT 'Jaydin'
UNION SELECT 'Jadiel'
UNION SELECT 'Roberto'
UNION SELECT 'Marquise'
UNION SELECT 'Harold'
UNION SELECT 'Jaeden'
UNION SELECT 'Devon'
UNION SELECT 'Pierce'
UNION SELECT 'Brennen'
UNION SELECT 'Rishi'
UNION SELECT 'Sonny'
UNION SELECT 'Aidan'
UNION SELECT 'Randy'
UNION SELECT 'Tripp'
UNION SELECT 'Dereon'
UNION SELECT 'Cassius'
UNION SELECT 'Sheldon'
UNION SELECT 'Blaine'
UNION SELECT 'Jordon'
UNION SELECT 'Neil'
UNION SELECT 'Sage'
UNION SELECT 'Brenden'
UNION SELECT 'Frederick'
UNION SELECT 'Raphael'
UNION SELECT 'Kameron'
UNION SELECT 'Uriah'
UNION SELECT 'Lewis'
UNION SELECT 'Jaquan'
UNION SELECT 'Sawyer'
UNION SELECT 'Peter'
UNION SELECT 'Rex'
UNION SELECT 'Jayce'
UNION SELECT 'Kamden'
UNION SELECT 'Rene'
UNION SELECT 'Scott'
UNION SELECT 'Donte'
UNION SELECT 'Johnathon'
UNION SELECT 'Jonas'
UNION SELECT 'Santiago'
UNION SELECT 'Curtis'
UNION SELECT 'Dillan'
UNION SELECT 'Cash'
UNION SELECT 'Jack'
UNION SELECT 'Ronnie'
UNION SELECT 'Landyn'
UNION SELECT 'Cael'
UNION SELECT 'Yahir'
UNION SELECT 'Ari'
UNION SELECT 'Moises'
UNION SELECT 'Damarion'
UNION SELECT 'Robert'
UNION SELECT 'Austin'
UNION SELECT 'Alec'
UNION SELECT 'Hezekiah'
UNION SELECT 'Ramon'
UNION SELECT 'Darien'
UNION SELECT 'Cullen'
UNION SELECT 'Zackery'
UNION SELECT 'Yandel'
UNION SELECT 'Rodney'
UNION SELECT 'Demetrius'
UNION SELECT 'Juan'
UNION SELECT 'Dayton'
UNION SELECT 'Gael'
UNION SELECT 'Leandro'
UNION SELECT 'Sullivan'
UNION SELECT 'Caden'
UNION SELECT 'Valentin'
UNION SELECT 'Jesus'
UNION SELECT 'Wade'
UNION SELECT 'Maddox'
UNION SELECT 'Dashawn'
UNION SELECT 'Gabriel'
UNION SELECT 'Gary'
UNION SELECT 'Armani'
UNION SELECT 'Jesse'
UNION SELECT 'Konner'
UNION SELECT 'Mohammed'
UNION SELECT 'Liam'
UNION SELECT 'Angelo'
UNION SELECT 'Brodie'
UNION SELECT 'Yael'
UNION SELECT 'Jairo'
UNION SELECT 'Conor'
UNION SELECT 'Raymond'
UNION SELECT 'Esteban'
UNION SELECT 'Dylan'
UNION SELECT 'Porter'
UNION SELECT 'Nathan'
UNION SELECT 'James'
UNION SELECT 'Mohamed'
UNION SELECT 'Brayden'
UNION SELECT 'Matias'
UNION SELECT 'Francisco'
UNION SELECT 'Jonathon'
UNION SELECT 'Zaiden'
UNION SELECT 'Bobby'
UNION SELECT 'Mauricio'
UNION SELECT 'Alex'
UNION SELECT 'Rudy'
UNION SELECT 'Romeo'
UNION SELECT 'Jaxson'
UNION SELECT 'Guillermo'
UNION SELECT 'Daniel'
UNION SELECT 'Cade'
UNION SELECT 'Bradley'
UNION SELECT 'Alfonso'
UNION SELECT 'Keenan'
UNION SELECT 'Conner'
UNION SELECT 'Darian'
UNION SELECT 'Caleb'
UNION SELECT 'Luka'
UNION SELECT 'Alexis'
UNION SELECT 'Kenny'
UNION SELECT 'Holden'
UNION SELECT 'Marc'
UNION SELECT 'Mike'
UNION SELECT 'Kenyon'
UNION SELECT 'Conrad'
UNION SELECT 'Miles'
UNION SELECT 'Rodolfo'
UNION SELECT 'Rogelio'
UNION SELECT 'Bernard'
UNION SELECT 'Kaleb'
UNION SELECT 'Arturo'
UNION SELECT 'Bridger'
UNION SELECT 'Boston'
UNION SELECT 'Tomas'
UNION SELECT 'Pranav'
UNION SELECT 'Elian'
UNION SELECT 'Kyle'
UNION SELECT 'Khalil'
UNION SELECT 'Alberto'
UNION SELECT 'Niko'
UNION SELECT 'Samson'
UNION SELECT 'Gregory'
UNION SELECT 'Brody'
UNION SELECT 'Dario'
UNION SELECT 'Rashad'
UNION SELECT 'Samir'
UNION SELECT 'Alvaro'
UNION SELECT 'Kayden'
UNION SELECT 'Bo'
UNION SELECT 'Ismael'
UNION SELECT 'Keith'
UNION SELECT 'Bentley'
UNION SELECT 'Matteo'
UNION SELECT 'Jamarion'
UNION SELECT 'Colton'
UNION SELECT 'Braylen'
UNION SELECT 'Patrick'
UNION SELECT 'Semaj'
UNION SELECT 'Aydan'
UNION SELECT 'Deven'
UNION SELECT 'Kyan'
UNION SELECT 'Raul'
UNION SELECT 'Santos'
UNION SELECT 'Demarion'
UNION SELECT 'Zain'
UNION SELECT 'Maxim'
UNION SELECT 'Alexander'
UNION SELECT 'Dangelo'
UNION SELECT 'Jadon'
UNION SELECT 'Harper'
UNION SELECT 'Alonzo'
UNION SELECT 'Diego'
UNION SELECT 'Zayne'
UNION SELECT 'Kaeden'
UNION SELECT 'Giovani'
UNION SELECT 'Damion'
UNION SELECT 'Ayden'
UNION SELECT 'Johnny'
UNION SELECT 'Mathias'
UNION SELECT 'Javier'
UNION SELECT 'Trent'
UNION SELECT 'Maurice'
UNION SELECT 'Beckham'
UNION SELECT 'Max'
UNION SELECT 'Michael'
UNION SELECT 'Madden'
UNION SELECT 'Zane'
UNION SELECT 'Morgan'
UNION SELECT 'Tyson'
UNION SELECT 'Demarcus'
UNION SELECT 'Damien'
UNION SELECT 'Israel'
UNION SELECT 'Jameson'
UNION SELECT 'Malik'
UNION SELECT 'Corey'
UNION SELECT 'Ivan'
UNION SELECT 'London'
UNION SELECT 'Jett'
UNION SELECT 'Kareem'
UNION SELECT 'Joseph'
UNION SELECT 'Noe'
UNION SELECT 'Jarrett'
UNION SELECT 'Ricardo'
UNION SELECT 'Emiliano'
UNION SELECT 'Jeffrey'
UNION SELECT 'Jaydan'
UNION SELECT 'Edward'
UNION SELECT 'Finnegan'
UNION SELECT 'Josue'
UNION SELECT 'Glenn'
UNION SELECT 'Bruno'
UNION SELECT 'Allan'
UNION SELECT 'Graham'
UNION SELECT 'Steve'
UNION SELECT 'Zechariah'
UNION SELECT 'Dominic'
UNION SELECT 'Justus'
UNION SELECT 'Cesar'
UNION SELECT 'Jamie'
UNION SELECT 'Giovanny'
UNION SELECT 'Vincent'
UNION SELECT 'Colt'
UNION SELECT 'Jean'
UNION SELECT 'Malakai'
UNION SELECT 'Braydon'
UNION SELECT 'Deon'
UNION SELECT 'Jared'
UNION SELECT 'Kadyn'
UNION SELECT 'Ryan'
UNION SELECT 'Braden'
UNION SELECT 'Kai'
UNION SELECT 'Amari'
UNION SELECT 'Dawson'
UNION SELECT 'Zack'
UNION SELECT 'Clay'
UNION SELECT 'Eugene'
UNION SELECT 'Saul'
UNION SELECT 'Joshua'
UNION SELECT 'Kash'
UNION SELECT 'Drake'
UNION SELECT 'Matthew'
UNION SELECT 'Mason'
UNION SELECT 'Lucas'
UNION SELECT 'Omar'
UNION SELECT 'Adam'
UNION SELECT 'Cyrus'
UNION SELECT 'Elijah'
UNION SELECT 'Stephen'
UNION SELECT 'Sterling'
UNION SELECT 'Kane'
UNION SELECT 'Keyon'
UNION SELECT 'Zackary'
UNION SELECT 'Jayvon'
UNION SELECT 'Darren'
UNION SELECT 'Frank'
UNION SELECT 'Jaidyn'
UNION SELECT 'Korbin'
UNION SELECT 'Kenneth'
UNION SELECT 'Nathanael'
UNION SELECT 'Colten'
UNION SELECT 'Beau'
UNION SELECT 'Kian'
UNION SELECT 'Makai'
UNION SELECT 'Dean'
UNION SELECT 'Draven'
UNION SELECT 'Salvatore'
UNION SELECT 'Cohen'
UNION SELECT 'Edwin'
UNION SELECT 'Desmond'
UNION SELECT 'Layne'
UNION SELECT 'Elliot'
UNION SELECT 'Prince'
UNION SELECT 'Jorge'
UNION SELECT 'Zaid'
UNION SELECT 'Griffin'
UNION SELECT 'Marcos'
UNION SELECT 'Tony'
UNION SELECT 'Kadin'
UNION SELECT 'Damian'
UNION SELECT 'Thaddeus'
UNION SELECT 'Josiah'
UNION SELECT 'Brycen'
UNION SELECT 'Cody'
UNION SELECT 'Nicolas'
UNION SELECT 'Roderick'
UNION SELECT 'Jovan'
UNION SELECT 'Asa'
UNION SELECT 'Jaylin'
UNION SELECT 'Marley'
UNION SELECT 'Terrell'
UNION SELECT 'Gustavo'
UNION SELECT 'Axel'
UNION SELECT 'Dustin'
UNION SELECT 'Jaden'
UNION SELECT 'Kade'
UNION SELECT 'Marcus'
UNION SELECT 'Johnathan'
UNION SELECT 'Lance'
UNION SELECT 'Tristin'
UNION SELECT 'Carlo'
UNION SELECT 'Addison'
UNION SELECT 'Memphis'
UNION SELECT 'Ethan'
UNION SELECT 'Harrison'
UNION SELECT 'Alvin'
UNION SELECT 'Randall'
UNION SELECT 'Vaughn'
UNION SELECT 'Micheal'
UNION SELECT 'Leonard'
UNION SELECT 'Royce'
UNION SELECT 'Slade'
UNION SELECT 'Titus'
UNION SELECT 'Solomon'
UNION SELECT 'Darion'
UNION SELECT 'Reilly'
UNION SELECT 'Dakota'
UNION SELECT 'Kolby'
UNION SELECT 'Terrence'
UNION SELECT 'Kingston'
UNION SELECT 'Tate'
UNION SELECT 'Damon'
UNION SELECT 'Marques'
UNION SELECT 'Emanuel'
UNION SELECT 'Trevin'
UNION SELECT 'Asher'
UNION SELECT 'Bailey'
UNION SELECT 'Kendrick'
UNION SELECT 'Owen'
UNION SELECT 'Nico'
UNION SELECT 'Kendall'
UNION SELECT 'Karson'
UNION SELECT 'Jovanny'
UNION SELECT 'Wesley'
UNION SELECT 'Jeremiah'
UNION SELECT 'Mitchell'
UNION SELECT 'Aaron'
UNION SELECT 'Jefferson'
UNION SELECT 'Geovanni'
UNION SELECT 'Mario'
UNION SELECT 'Antony'
UNION SELECT 'Craig'
UNION SELECT 'Braedon'
UNION SELECT 'Ryland'
UNION SELECT 'Justice'
UNION SELECT 'Anderson'
UNION SELECT 'Marlon'
UNION SELECT 'Krish'
UNION SELECT 'Caiden'
UNION SELECT 'Jaiden'
UNION SELECT 'Kamari'
UNION SELECT 'Kasen'
UNION SELECT 'Rafael'
UNION SELECT 'Izaiah'
UNION SELECT 'Keon'
UNION SELECT 'Kelton'
UNION SELECT 'Maverick'
UNION SELECT 'Deegan'
UNION SELECT 'Moshe'
UNION SELECT 'Ralph'
UNION SELECT 'Charlie'
UNION SELECT 'Brennan'
UNION SELECT 'Bryson'
UNION SELECT 'Lincoln'
UNION SELECT 'Damari'
UNION SELECT 'Noel'
UNION SELECT 'Carl'
UNION SELECT 'Eliezer'
UNION SELECT 'Raiden'
UNION SELECT 'Aarav'
UNION SELECT 'Mathew'
UNION SELECT 'Kyson'
UNION SELECT 'Ramiro'
UNION SELECT 'Chaim'
UNION SELECT 'Aden'
UNION SELECT 'Jay'
UNION SELECT 'Jamar'
UNION SELECT 'Julien'
UNION SELECT 'Davin'
UNION SELECT 'Ryder'
UNION SELECT 'Quentin'
UNION SELECT 'Julius'
UNION SELECT 'Troy'
UNION SELECT 'Alonso'
UNION SELECT 'Zayden'
UNION SELECT 'Derek'
UNION SELECT 'Arthur'
UNION SELECT 'Orlando'
UNION SELECT 'Felix'
UNION SELECT 'Pablo'
UNION SELECT 'Hugh'
UNION SELECT 'Shaun'
UNION SELECT 'Koen'
UNION SELECT 'Ezekiel'
UNION SELECT 'Talon'
UNION SELECT 'Zaire'
UNION SELECT 'Tyrone'
UNION SELECT 'Pedro'
UNION SELECT 'Stanley'
UNION SELECT 'Andre'
UNION SELECT 'Baron'
UNION SELECT 'Julio'
UNION SELECT 'Tyrese'
UNION SELECT 'Nikolas'
UNION SELECT 'Landon'
UNION SELECT 'Javion'
UNION SELECT 'Efrain'
UNION SELECT 'Brent'
UNION SELECT 'Jerimiah'
UNION SELECT 'Dax'
UNION SELECT 'Ishaan'
UNION SELECT 'Dexter'
UNION SELECT 'Ross'
UNION SELECT 'Ronald'
UNION SELECT 'Ian'
UNION SELECT 'Brandon'
UNION SELECT 'Keagan'
UNION SELECT 'Xander'
UNION SELECT 'Jeremy'
UNION SELECT 'Kason'
UNION SELECT 'Carlos'
UNION SELECT 'Urijah'
UNION SELECT 'Marvin'
UNION SELECT 'Abel'
UNION SELECT 'Alejandro'
UNION SELECT 'Jagger'
UNION SELECT 'Bryant'
UNION SELECT 'Leonidas'
UNION SELECT 'Trace'
UNION SELECT 'Adriel'
UNION SELECT 'Sean'
UNION SELECT 'Jayvion'
UNION SELECT 'Jordyn'
UNION SELECT 'Taylor'
UNION SELECT 'Keaton'
UNION SELECT 'Ace'
UNION SELECT 'Jayson'
UNION SELECT 'Seamus'
UNION SELECT 'Abraham'
UNION SELECT 'Kale'
UNION SELECT 'Tyshawn'
UNION SELECT 'Konnor'
UNION SELECT 'Vance'
UNION SELECT 'Rory'
UNION SELECT 'Braxton'
UNION SELECT 'Cole'
UNION SELECT 'German'
UNION SELECT 'Eric'
UNION SELECT 'Darwin'
UNION SELECT 'Fernando'
UNION SELECT 'Jamal'
UNION SELECT 'Riley'
UNION SELECT 'Aron'
UNION SELECT 'Triston'
UNION SELECT 'Remington'
UNION SELECT 'Jacob'
UNION SELECT 'Henry'
UNION SELECT 'Ben'
UNION SELECT 'Jamir'
UNION SELECT 'Gavin'
UNION SELECT 'Trevor'
UNION SELECT 'Ernest'
UNION SELECT 'Branden'
UNION SELECT 'Nehemiah'
UNION SELECT 'Davon'
UNION SELECT 'Tyree'
UNION SELECT 'Layton'
UNION SELECT 'Connor'
UNION SELECT 'George'
UNION SELECT 'Isaac'
UNION SELECT 'Roy'
UNION SELECT 'Marquis'
UNION SELECT 'Jamari'
UNION SELECT 'Julian'
UNION SELECT 'Jaylen'
UNION SELECT 'Rowan'
UNION SELECT 'Jeffery'
UNION SELECT 'Bruce'
UNION SELECT 'Myles'
UNION SELECT 'Dorian'
UNION SELECT 'Luke'
UNION SELECT 'Lamar'
UNION SELECT 'Kasey'
UNION SELECT 'Miguel'
UNION SELECT 'Maximilian'
UNION SELECT 'Van'
UNION SELECT 'Avery'
UNION SELECT 'Reagan'
UNION SELECT 'Donovan'
UNION SELECT 'Dalton'
UNION SELECT 'Declan'
UNION SELECT 'Aryan'
UNION SELECT 'Brendan'
UNION SELECT 'Mohammad'
UNION SELECT 'Bradyn'
UNION SELECT 'Heath'
UNION SELECT 'Jase'
UNION SELECT 'Gunnar'
UNION SELECT 'Kolten'
UNION SELECT 'Ezra'
UNION SELECT 'Wilson'
UNION SELECT 'Vicente'
UNION SELECT 'Rey'
UNION SELECT 'Kelvin'
UNION SELECT 'Warren'
UNION SELECT 'Jamison'
UNION SELECT 'Joaquin'
UNION SELECT 'Trevon'
UNION SELECT 'Jimmy'
UNION SELECT 'Marcel'
UNION SELECT 'Malcolm'
UNION SELECT 'Nathen'
UNION SELECT 'Matthias'
UNION SELECT 'Devin'
UNION SELECT 'Adrian'
UNION SELECT 'Braeden'
UNION SELECT 'Junior'
UNION SELECT 'Erik'
UNION SELECT 'Walker'
UNION SELECT 'Bronson'
UNION SELECT 'Gaven'
UNION SELECT 'Grant'
UNION SELECT 'Devyn'
UNION SELECT 'Leroy'
UNION SELECT 'Brenton'
UNION SELECT 'Ahmad'
UNION SELECT 'Eden'
UNION SELECT 'Finley'
UNION SELECT 'Messiah'
UNION SELECT 'Tucker'
UNION SELECT 'Gage'
UNION SELECT 'Roger'
UNION SELECT 'Camden'
UNION SELECT 'Angel'
UNION SELECT 'Houston'
UNION SELECT 'Keshawn'
UNION SELECT 'Roman'
UNION SELECT 'Cale'
UNION SELECT 'Cornelius'
UNION SELECT 'Ernesto'
UNION SELECT 'Yurem'
UNION SELECT 'Oswaldo'
UNION SELECT 'Colin'
UNION SELECT 'Nikolai'
UNION SELECT 'River'
UNION SELECT 'Dallas'
UNION SELECT 'Sergio'
UNION SELECT 'Finn'
UNION SELECT 'Issac'
UNION SELECT 'Jerry'
UNION SELECT 'Tanner'
UNION SELECT 'Mark'
UNION SELECT 'Corbin'
UNION SELECT 'Enrique'
UNION SELECT 'Brian'
UNION SELECT 'Nathaniel'
UNION SELECT 'Ayaan'
UNION SELECT 'Trystan'
UNION SELECT 'Benjamin'
UNION SELECT 'Leland'
UNION SELECT 'Milton'
UNION SELECT 'Deandre'
UNION SELECT 'Clarence'
UNION SELECT 'Jasiah'
UNION SELECT 'Clayton'
UNION SELECT 'Kaiden'
UNION SELECT 'Malaki'
UNION SELECT 'Jakobe'
UNION SELECT 'Everett'
UNION SELECT 'Jakob'
UNION SELECT 'Jovanni'
UNION SELECT 'Brock'
UNION SELECT 'Hugo'
UNION SELECT 'Carson'
UNION SELECT 'Jude'
UNION SELECT 'Maxwell'
UNION SELECT 'Alijah'
UNION SELECT 'Aedan'
UNION SELECT 'Savion'
UNION SELECT 'Aidyn'
UNION SELECT 'Cordell'
UNION SELECT 'Reynaldo'
UNION SELECT 'Xavier'
UNION SELECT 'Broderick'
UNION SELECT 'Adrien'
UNION SELECT 'Landen'
UNION SELECT 'Andrew'
UNION SELECT 'Gilberto'
UNION SELECT 'Rodrigo'
UNION SELECT 'Leo'
UNION SELECT 'Cayden'
UNION SELECT 'Keegan'
UNION SELECT 'Zachery'
UNION SELECT 'Javon'
UNION SELECT 'Isai'
UNION SELECT 'Darius'
UNION SELECT 'Reese'
UNION SELECT 'Will'
UNION SELECT 'Dominique'
UNION SELECT 'Reginald'
UNION SELECT 'Maximillian'
UNION SELECT 'Giovanni'
UNION SELECT 'Malachi'
UNION SELECT 'Chase'
UNION SELECT 'Howard'
UNION SELECT 'Nelson'
UNION SELECT 'William'
UNION SELECT 'Jaron'
UNION SELECT 'Jessie'
UNION SELECT 'Devan'
UNION SELECT 'Turner'
UNION SELECT 'Cameron'
UNION SELECT 'Francis'
UNION SELECT 'Irvin'
UNION SELECT 'Martin'
UNION SELECT 'Tommy'
UNION SELECT 'Calvin'
UNION SELECT 'Richard'
UNION SELECT 'Paul'
UNION SELECT 'Alden'
UNION SELECT 'Chris'
UNION SELECT 'Victor'
UNION SELECT 'Camren'
UNION SELECT 'Ezequiel'
UNION SELECT 'Markus'
UNION SELECT 'Isiah'
UNION SELECT 'Emmett'
UNION SELECT 'Jeramiah'
UNION SELECT 'Antoine'
UNION SELECT 'Dillon'
UNION SELECT 'Timothy'
UNION SELECT 'Dante'
UNION SELECT 'Brooks'
UNION SELECT 'Jovany'
UNION SELECT 'Zander'
UNION SELECT 'Landin'
UNION SELECT 'Deangelo'
UNION SELECT 'Edgar'
UNION SELECT 'Yair'
UNION SELECT 'Sammy'
UNION SELECT 'Tobias'
UNION SELECT 'Lamont'
UNION SELECT 'Rhett'
UNION SELECT 'Branson'
UNION SELECT 'Agustin'
UNION SELECT 'Nolan'
UNION SELECT 'Makhi'
UNION SELECT 'Travis'
UNION SELECT 'Kael'
UNION SELECT 'Reuben'
UNION SELECT 'Ignacio'
UNION SELECT 'Hudson'
UNION SELECT 'Harry'
UNION SELECT 'Lyric'
UNION SELECT 'Brady'
UNION SELECT 'Willie'
UNION SELECT 'Marco'
UNION SELECT 'Alessandro'
UNION SELECT 'Rylee') AS OtherNames
WHERE FP.Sex = 'M'
AND NOT EXISTS (SELECT * FROM dbo.FakePeople FP2 WHERE FP2.FirstName = OtherFirstName AND FP2.Surname = FP.Surname AND FP2.Sex = 'M')