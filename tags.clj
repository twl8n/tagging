(ns tagging
  )



;; Multi-value not flat.
;; Complex and-ed keys are not flat.
;; What we need are tuples?
(def flat-tags 
  [:name "Daisy"
   :color :black
   :color :white
   :breed "Boston terrier"
   :born-date "2002-06-04"
   :born-city "Richmond"
   :born-state "VA"
   :born {:city "Richmond" :state "VA" :date "2002-06-04"}
   :lived {:city "Charlottesville" :state "VA"}
   :lived {:city "Richmond" :state "VA"}
   :lived {:city "Sacramento" :state "CA"}
   :lived {:city "Lovingston" :state "VA"}
   :lived {:city "Paris" :state "VA"}
   :lived {:city "Paris" :state "TX" :date "2005-04-08"}
   :address {:city "Richmond" :state "VA"}
   :battery nil])
(comment
  ;; if color==black
  ;; if color==black and color==white
  ;; if address/city==Paris
  ;; if address/city==Paris and address/state=TX
  ;; if */city==Richmond
  (reduce (fn [accum [kk vv]] (if (= kk :address) (conj accum vv) accum)) [] (partition 2 flat-tags))
  
  (reduce (fn [accum [kk vv]] (if (some? (:city vv)) (conj accum vv) accum)) [] (partition 2 flat-tags))
  (reduce (fn [accum [kk vv]] (if (= "Paris" (:city vv)) (conj accum vv) accum)) [] (partition 2 flat-tags))
  
  (reduce (fn [accum [kk vv]] (if (and (= kk :address) (= "Paris" (:city vv))) (conj accum vv) accum)) [] (partition 2 flat-tags))
  (reduce (fn [accum [kk vv]] (if (= kk :color) (conj accum vv) accum)) [] (partition 2 flat-tags))
    (reduce (fn [accum [kk vv]] (if (= kk :born-date) (conj accum vv) accum)) [] (partition 2 flat-tags))

  (filter (fn [[kk vv]] (= kk :color)) (partition 2 flat-tags))
  )


(def tags
  [[{:name "Daisy"} ;; list of hashmaps is pointless. Render keys as fns
    {:color :black}
    {:color :white}
    {:breed "Boston terrier"}
    {:born {:date "2002-06-04" ;; (:date (:born %))
            :city "Richmond"   
            :state "VA"}}
    {:address [{:city "Charlottesville" :state "VA"} ;; (:state (first (filter #(= "Charlottesville" (:city %)) (:address (nth tags 1)))))
               {:city "Sacramento" :state "CA"}      ;; (map :state (filter #(= "Charlottesville" (:city %)) (remove nil? (mapcat :address tags))))
               {:city "Lovingston" :state "VA"}]}
    {:battery nil}]
   {:name "Daisy"
    :color [:black :white]
    :breed "Boston terrier"
    :born {:date "2002-06-04"
           :city "Richmond"
           :state "VA"}
    :address [{:city "Charlottesville" :state "VA"}
              {:city "Sacramento" :state "CA"}
              {:city "Lovingston" :state "VA"}]
    :battery nil}
   {:name "Daisy"
    :color [:black :white]
    :breed "Boston terrier"
    :born {:date "2002-06-04"
           :city "Richmond"
           :state "VA"}
    :battery nil}
   {:name "drill"
    :brand "Detroit"
    :chuck {:inch 3/8}
    :amps 4
    :model "F48"
    :cord-length {:feet 6}
    :made-in {:country "CN"}}])

(comment
  (binding [*print-dup* true] (println (first tags)))
  )

;; Can these include macros? Or simply coalesce included fields.
;; Fields with a nil value aren't displayed, and are considered null or n/a.
;; Everything includes root.

;; Simplified ontology, existing only to streamline addition of common tags
;; Is this an ontology, or a dictionary?
;; Can an item use multiple templates?
;; Templates exist as a way to create data entry UI and sanity check entries.
;; select :drill where :amps is nil
;; Software can traverse this auto-including more granular items where possible
;; corded-tool can auto-include electrical-item instead of individual fields [:volts :amps]
(def template
  [{:root [:id :description :name :made-in]}
   {:single-item [:weight :color]}
   {:set-item [:count [:include :single-item]]}
   {:bolt [:diameter :thread-count :length :hardness [:include :single-item]]}
   {:electrical-item [:volts :amps]}
   {:cordless-item [:amps :volts :number-included-batteries [:include :single-item]]}
   {:cordless-tool [:amps :model :power-type [:include :cordless-item] [:include :single-item]]}
   {:corded-tool [:amps :volts :model :power-type :grounded-cord :plug-type [:include :single-item]]}
   {:drill [:brand :chuck :amps :model :made-in [:include :power-tool]]}
   {:corded-drill [:cord-length [:include :drill]]}
   {:cordless-drill [[:include :battery-item] [:include :drill]]}
   {:dog [:name :color :breed :birth-date :birth-place]}])

;; Doing this would lead to an detailed ontology. Humans can't the ontology. The ontology will never be complete.
;; Should use spec for this?
(def template-complex
  [{:name "drill"
    :brand :string
    :chuck :size
    :nominal-chuck [1/4 3/8 1/2 3/4]
    :amps :number
    :model :string
    :cord-length :size
    :made-in :country-code}
   {:size [:units :number]}
   {:units ["inch" "millimeter"]}])

