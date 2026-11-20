(defrule ask-prochnost
=>
    (assert (prochnost (ask-number "Прочность бетона в МПа")))
)

(defrule ask-agressiv
    (prochnost ?)
=>
    (assert (agressiv (ask-number "Агрессивность среды (0 — нет, 1 — слабая, 2 — средняя, 3 — сильная)")))
)

(defrule ask-cement
    (agressiv ?a)
    (test (> ?a 0))
=>
    (assert (cement (ask-number "Цемент, кг на 1 м3")))
)

(defrule ask-voda
    (agressiv ?a)
    (test (> ?a 0))
=>
    (assert (voda (ask-number "Вода, кг на 1 м3")))
)

(defrule ask-podvergaetcya-zamorazivaniyu
    (agressiv ?a)
    (or (test (= ?a 0))
        (voda ?))
=>
    (assert (freeze (ask-yes-no "Конструкция подвергается замораживанию и оттаиванию")))
)

(defrule ask-rezim
    (freeze TRUE)
=>
    (assert (rezim (ask-number "Режим среды (1 — насыщение водой с солями, 2 — насыщение пресной водой, 3 — эпизодическое увлажнение, 4 — влажный воздух, но под навесом, без осадков, 5 — в грунте или под водой, замерзает раз в год)")))
)

(defrule ask-moroz
    (freeze TRUE)
=>
    (assert (moroz (ask-number "Расчетная зимняя температура: сколько градусов мороза (например, 67)")))
)

(defrule opredelit-klass
    (prochnost ?p)
    (ryad_klassov ?k)
    (test (<= ?k (* 0.8 ?p)))
    (not (and (ryad_klassov ?k2)
              (test (< ?k2 ?k))
              (test (<= ?k2 (* 0.8 ?p))))
=>
    (assert (klass ?k))              
)

(defrule wodonepronez-ok-bez-marki
    (agressiv ?a)
    (marka_W ?t ?a 0)
=>
    (assert (wodonepronez ?t))
)

(defrule wodonepronez-ok-s-mark
    (agressiv ?a)
    (marka_W ?t ?a ?m)
    (test (> ?m 0))
    (predel_VC ?m ?lim)
    (cement ?c)
    (test (> ?c 0))
    (voda ?v)
    (test (<= (/ ?v ?c) ?lim))
=>
    (assert (wodonepronez ?t))
)

(defrule morozostoykost-ok-bez-zamorazivaniya
    (freeze FALSE)
=>
    (assert (morozostoykost TRUE))
)

(defrule morozostoykost-ok-s-zamorazivaniem
    (freeze TRUE)
    (rezim ?r)
    (moroz ?m)
    (marka_F ?r ?z ?method ?marka)
    (test (= ?z (zona-moroza ?m)))
    (predel_F ?method ?lim)
    (test (<= ?marka ?lim))
=>
    (assert (morozostoykost TRUE))
)

(defrule naznachenie-PN
    (declare (salience -10))
    (klass ?k)
    (test (>= ?k 20))
    (wodonepronez PN)
    (morozostoykost TRUE)
    (not (naznachenie ?))
=> 
    (assert (naznachenie PN))
)

(defrule naznachenie-ZB
    (declare (salience -20))
    (klass ?k)
    (test (>= ?k 15))
    (wodonepronez ZB)
    (morozostoykost TRUE)
    (not (naznachenie ?))
=>
    (assert (naznachenie ZB))
)

(defrule ask-szhatie
    (declare (salience -25))
    (klass ?k)
    (test (>= ?k 3.5))
    (wodonepronez BET)
    (morozostoykost TRUE)
    (not (naznachenie ?))
=>
    (assert (szhatie (ask-yes-no "Работает только на сжатие")))
)

(defrule ask-opasno
    (szhatie FALSE)
=>
    (assert (opasno (ask-yes-no "Разрушение опасно для людей (например, перекрытие, лестница)")))
)

(defrule element-ok
    (szhatie TRUE)
=>
    (assert (element-ok TRUE))
)

(defrule element-ok-2
    (opasno FALSE)
=>
    (assert (element-ok TRUE))
)

(defrule naznachenie-BET
    (declare (salience -30))
    (element-ok TRUE)
    (not (naznachenie ?))
=>
    (assert (naznachenie BET))
)

(defrule ne-podhodit
    (declare (salience -100))
    (not (naznachenie ?))
=>
    (printout t "Для заданных условий не найдено подходящего назначения бетона." crlf)
) 

(defrule vyvod-otveta
    (naznachenie ?n)
=>
    (switch ?n
        (case PN then (bind ?tekst "предварительно напряженные конструкции (ПН)"))
        (case ZB then (bind ?tekst "обычный железобетон (ZB)"))
        (case BET then (bind ?tekst "бетонные конструкции (без арматуры)"))
    )
    (printout t "Бетон подходит для " ?tekst "!" crlf)
)