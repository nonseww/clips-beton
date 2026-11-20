(deffunction zona-moroza (?moroz)
    (if (> ?moroz 40) then 1
    else (if (> ?moroz 20) then 2
    else (if (> ?moroz 5) then 3
    else 4
))))

(deffunction ask-number (?question)
    (printout t ?question "? ")
    (bind ?answer (read))
    (if (and (numberp ?answer) (>= ?answer 0)) then
        (bind ?result ?answer)
    else 
        (printout t "Введите неотрицательное число!" crlf)
        (bind ?result (ask-number ?question))
    )
    ?result
)

(deffunction ask-yes-no (?question)
    (printout t ?question " (да/нет)? ")
    (bind ?answer (readline))
    (if (eq ?answer "да") then
        (bind ?result TRUE)
    else
        (if (eq ?answer "нет") then
            (bind ?result FALSE)
        else
            (printout t "Пожалуйста, ответьте да или нет!" crlf)
            (bind ?result (ask-yes-no ?question))
    ))
    ?result
)

