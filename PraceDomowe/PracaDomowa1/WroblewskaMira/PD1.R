library(dplyr)

df <- read.csv("house_data.csv")


# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?
df %>% 
  filter(waterfront == 1) %>% 
  filter(grade >= median(grade)) %>% 
  summarise(�rednia_cena = mean(price))
  

# Odp: 2302236


# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?

mediana2 <- df %>% 
              filter(floors==2) %>% 
              summarise(mediana2 = median(bathrooms))
mediana3 <- df %>% 
              filter(floors==3) %>% 
              summarise(mediana3 = median(bathrooms))
mediana2>mediana3

# Odp: Nie maj� wi�kszej, maj� r�wn�


# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?

num_NW <- df %>% 
            filter(lat>=mean(lat) & long<=mean(long)) %>%
            summarise(num_NW = n())

num_SE <- df %>% 
            filter(lat<=mean(lat) & long>=mean(long)) %>% 
            summarise(num_SE = n())

(num_NW-num_SE)/(num_NW+num_SE)*100
# Odp: 12.91701


# 4. Jak zmienia�a si� (mediana) liczba �azienek dla nieruchomo�ci wybudownych w latach 90 XX wieku wzgl�dem nieruchmo�ci wybudowanych roku 2000?

df %>% 
  filter(yr_built>=1990 & yr_built<2010) %>%
  select(yr_built, bathrooms) %>% 
  group_by(yr_built) %>% 
  summarise(bathrooms_median = median(bathrooms)) %>% 
  arrange(yr_built)




# Odp: Jest sta�a


# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?

df %>% 
  filter(lat>=mean(lat)) %>% 
  group_by(waterfront) %>% 
  summarise(quantiles_count = quantile(grade, c(0.25, 0.75)), quantiles = c(0.25, 0.75))

# Odp: Dla po�o�onych nad wod� 0.25 - 8, 0.75 - 11, a dla nie nad wod� 0,25- 7, 0,75 - 8


# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?

top_zipcode <- df %>% 
  group_by(zipcode) %>% 
  summarise(ilosc = n()) %>% 
  arrange(desc(ilosc)) %>% 
  top_n(1)

quantiles_price <- df %>% 
  filter(zipcode == top_zipcode$zipcode) %>% 
  summarise(quantiles_count = quantile(price, c(0.25, 0.75)), quantiles = c(0.25, 0.75)) %>% 
  arrange(quantiles)

quantiles_price[2,"quantiles_count"]-quantiles_price[1,"quantiles_count"]
# Odp: 262875


# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?
liczba_wyzsza_srednia15 <- df %>% 
                              filter(sqft_living<sqft_living15) %>% 
                              summarise(liczba = n())
liczba_wszystkich <- df %>% 
                        summarise(liczba = n())
(liczba_wyzsza_srednia15)/(liczba_wszystkich)*100


# Odp: 42.59473


# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dne) oraz zosta�y zbudowane po 1970?

df %>% 
  filter(price>quantile(price, 0.75) & yr_renovated >= 2012 & yr_built > 1970) %>% 
  select(id, bedrooms)
# Odp:3, 4 albo 5


# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).

df %>% 
  filter(sqft_living < (quantile(sqft_living, 0.25)-1.5*(quantile(sqft_living, 0.75)-quantile(sqft_living, 0.25))) | sqft_living > (quantile(sqft_living, 0.75)+1.5*(quantile(sqft_living, 0.75)-quantile(sqft_living, 0.25)))) %>% 
  summarise(ilosc = n())
# Odp: 572


# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.

df %>% 
  summarise(cena_za_m2 = price/(sqft_living*0.093)) %>% 
  arrange(desc(cena_za_m2)) %>% 
  top_n(1)
# Odp: 8711.171
