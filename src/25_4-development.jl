### A Pluto.jl notebook ###
# v0.20.4

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ b2da04e0-ff6f-11ef-3db4-8165a7ebfc2e
using PlutoDevMacros

# ╔═╡ 9d35446e-b838-493d-a70c-b0d526050b40
begin
	using PlutoUI
	using PlutoExtras
	using PlutoExtras.StructBondModule
	using PlutoPlotly
	using HypertextLiteral
	using Latexify
	using LaTeXStrings
	using UnitfulLatexify
	using Handcalcs
	using PrettyTables
	using SummaryTables
	using Symbolics
end

# ╔═╡ 4ee6a7f9-7b46-4315-91d9-045ae6cb6ae6
module MyUnits
	using Unitful
	@unit kgf 	"kgf" 	KilogramForce 	1.0u"kg"*Unitful.ge 		false
end # module MyUnits

# ╔═╡ 80f18465-cc64-4335-bc7b-55df0af9b6c2
@fromparent import *

# ╔═╡ 027cc2b1-c160-46f7-857b-c16ce95ed18c
names(ACI318_25ReinforcementDetails; all=true)

# ╔═╡ ae310438-a7cb-4de3-8778-fa189a100a1b
md"""
# Input data
"""

# ╔═╡ 3d456a96-4138-4f53-a033-aa80cc1c39fa
begin 
bond_language = @BondsList "Language" begin
	"Language" = @bind language Select(
		[
			"en" => "English";
			"es" => "Español";
		], 
		default="es"
	)	
end
end

# ╔═╡ 42230b7f-8cd8-418e-af59-596c79a7fa43
begin
	text_settings = Dict(
		"en" => "Settings:",
		"es" => "Configuraciones:",
	)
	text_unit_system = Dict(
		"en" => "Unit System:",
		"es" => "Sistema de Unidades:",
	)

	
	bond_settings = @BondsList text_settings[language] begin
	
		text_unit_system[language] = @bind unit_system Select([
			"mks";
			"SI";
			"English";
		], default="mks",)
	end

	
end

# ╔═╡ 49c6b23d-58f2-49f2-a6f4-ba08a6ad4330
@bind reset_selected_to_defaults Button("Reset to default values")

# ╔═╡ a4cbd8fd-8c57-4bc0-a6d7-ba68714716dc
md"""
# Results
"""

# ╔═╡ c83108fe-c227-46db-bb15-a33d81ba2407
md"""
# Calculations
"""

# ╔═╡ ed5643bf-9147-4af3-828e-8b976af35624
if unit_system == "English"
	preferred_length = u"inch"
	preferred_force = u"lbf"
	preferred_stress = u"psi"

	f_c_min = 2_000.0#u"psi"
	f_c_max = 20_000.0#u"psi"
	f_c_default = 3_500.0#u"psi"
	f_c_increments = 500.0#u"psi"

	f_y_min = 20_000.0#u"psi"
	f_y_max = 200_000.0#u"psi"
	f_y_default = 60_000.0#u"psi"
	f_y_increments = 10_000.0#u"psi"

elseif unit_system == "SI"
	preferred_length = u"mm"
	preferred_force = u"kN"
	preferred_stress = u"MPa"

	f_c_min = 15.0#u"MPa"
	f_c_max = 200.0#u"MPa"
	f_c_default = 25.0#u"MPa"
	f_c_increments = 5.0#u"MPa"

	f_y_min = 140.0#u"MPa"
	f_y_max = 1500.0#u"MPa"
	f_y_default = 420.0#u"MPa"
	f_y_increments = 40.0#u"MPa"
	
elseif unit_system == "mks"
	preferred_length = u"cm"
	preferred_force = u"kgf"
	preferred_stress = u"kgf/cm^2"

	f_c_min = 150.0#u"kgf/cm^2"
	f_c_max = 2_000.0#u"kgf/cm^2"
	f_c_default = 250.0#u"kgf/cm^2"
	f_c_increments = 50.0#u"kgf/cm^2"

	f_y_min = 1500.0#u"kgf/cm^2"
	f_y_max = 15000.0#u"kgf/cm^2"
	f_y_default = 4200.0#u"kgf/cm^2"
	f_y_increments = 500.0#u"kgf/cm^2"
end; "Unit system: $unit_system" # if

# ╔═╡ b57018dc-8049-4653-9e20-698e16cc1552
begin
	text_data = Dict(
		"en" => "Materials:",
		"es" => "Materiales:",
	)
	text_concrete_strength = Dict(
		"en" => md"Concrete compressive strength, $br 
		``f'_c``, [ $(preferred_stress) ]:",
		
		"es" => md"Resistencia a compresión del concreto, $br 
		``f'_c``, [ $preferred_stress ] :",
	)
	text_lightweight_concrete = Dict(
		"en" => md"Lightweight concrete:",
		"es" => md"Concreto ligero:",
	);
	
	text_reinforcement_grade = Dict(
		"en" => md"Reinforcement grade, ``f_y``, [ ksi ]:",
		"es" => md"Grado del refuerzo, ``f_y``, [ ksi ]:",
	);
	
	bond_data = @BondsList text_data[language] begin
		
		text_concrete_strength[language] = @bind f_c_selected NumberField(
		f_c_min:f_c_increments:f_c_max, 
		default=f_c_default)
		
		text_lightweight_concrete[language] = @bind lightweight_concrete_selected Select([
			false => "No", 
			true => "Yes"
		], default=false)

		text_reinforcement_grade[language] = @bind reinforcement_grade_selected Select([
			40 => "Grade 40", 
			60 => "Grade 60", 
			75 => "Grade 75", 
			80 => "Grade 80", 
			100 => "Grade 100", 
			0 => "Custom", 
		], default=60)
		
	end

	
end

# ╔═╡ 4db40be3-65cf-4a21-836d-7672768db456
begin
	text_custom = Dict(
		"en" => "Custom data:",
		"es" => "Datos personalizados:",
	)
	text_custom_reinforcement_grade = Dict(
		"en" => md"Custom reinforcement grade, ``f_y``, [ $preferred_stress ]:",
		"es" => md"Grado del refuerzo personalizado, ``f_y``, [ $preferred_stress ]:",
	);

	if reinforcement_grade_selected == 0 
		bond_custom = @BondsList text_custom[language] begin
			text_custom_reinforcement_grade[language] = 
				@bind f_y_selected NumberField(
					f_y_min:f_y_increments:f_y_max, 
					default=f_y_default
				)
		end
		
	else
		bond_custom = @BondsList "" begin
			
		end
	end # if

	
end

# ╔═╡ 658d2f98-0244-49ca-8d40-8bee762e9288
	notes_es = [
		"1. TODAS LAS LONGITUDES ESTÁN EN $(preferred_length)",
		"2. LA LONGITUD DE DESARROLLO A TENSIÓN (ℓ_d) ES IGUAL A LA LONGITUD DE TRASLAPE \"CLASE A\".",
		"3. PARA DETERMINAR LA CATEGORÍA DE TRASLAPE, d_b SE DEFINE COMO EL DIÁMETRO DE LA BARRA DE MAYOR TAMAÑO POR TRASLAPAR.",
		"4. SE UTILIZARÁ LA LONGITUD DE TRASLAPE \"CATEGORÍA 1\" CUANDO LA SEPARACIÓN LIBRE ENTRE BARRAS EN EL TRASLAPE SEA IGUAL O MAYOR A 3d_b.",
		"5. SE UTILIZARÁ LA LONGITUD DE TRASLAPE \"CATEGORÍA 2\" CUANDO LA SEPARACIÓN LIBRE ENTRE BARRAS EN EL TRASLAPE SEA MENOR A 3d_b Y MAYOR A 2d_b.",
		"6. CUANDO LA SEPARACIÓN LIBRE ENTRE BARRAS EN EL TRASLAPE SEA IGUAL O MENOR A 2d_b, LOS TRASLAPES DEBERÁN SER ESCALONADOS DE TAL FORMA QUE NO MÁS DEL 50% DE LAS BARRAS SE TRASLAPEN EN UNA MISMA SECCIÓN. CONSULTE EL DETALLE \"CRITERIOR TÍPICOS DE SEPARACIÓN ENTRE TRASLAPE DE BARRAS Y TRASLAPES ESCALONADOS\" PARA DETERMINAR LA SEPARACIÓN LIBRE \"s\" ENTRE BARRAS EN TRASLAPES ESCALONADOS.",
		"7. EN CASO DE QUE LA SEPARACIÓN ENTRE BARRAS SEA DIFERENTE EN LAS CARAS OPUESTAS DE UNA COLUMNA, SE DEBERÁ UTILIZAR LA MENOR SEPARACIÓN PARA DETERMINAR LA CATEGORÍA DE TRASLAPE QUE APLIQUE.",
		"8. UNA BARRA DE LECHO INFERIOR SE DEFINE COMO AQUELLA QUE NO TIENE MÁS DE $(12.0u"inch" |> preferred_length) DE CONCRETO FRESCO POR DEBAJO DE ELLA.",
		"9. UNA BARRA \"OTRO\" INCLUYEN BARRAS DE LECHO SUPERIOR, DE CARA Y TODAS AQUELLAS QUE TENGAN MÁS DE $(12.0u"inch" |> preferred_length) DE CONCRETO FRESCO POR DEBAJO.",
		"10. PARA BARRAS CON RECUBRIMIENTO EPÓXICO, MULTIPLICAR LAS LONGITUDES DE TRASLAPE PARA BARRAS DEL LECHO INFERIOR POR 1.5, Y LAS LONGITUDES DE TRASLAPE PARA BARRAS \"OTRO\" POR 1.3.",
		"11. CUANDO SE TRASLAPEN BARRAS DE DIFERENTE DIÁMETRO, LA LONGITUD DE TRASLAPE SE DETERMINA CON BASE EN LA BARRA DE MENOR DIÁMETRO, PERO NO DEBERÁ SER MENOR A LA LONGITUD DE TRASLAPE \"CLASE A\" DE LA BARRA DE MAYOR DIÁMETRO.",
		"12. PARA RESISTENCIAS DEL CONCRETO QUE NO COINCIDAN CON LAS TABULADAS, UTILIZAR LAS LONGITUDES DE DESARROLLO Y TRASLAPE CORRESPONDIENTE A LA RESISTENCIA DE CONCRETO MENOR.",
		
	]

# ╔═╡ 22885e67-f717-415c-8c97-e16a3db44c39
	notes = [
		"1. ALL SPLICE LENGTHS ARE IN $(preferred_length)",
		"2. THE TENSION DEVELOPMENT LENGTH (ℓ_d) IS EQUAL TO THE SCHEDULED \"CLASS A\" LAP SPLICE LENGTH.",
		"3. FOR DETERMINING THE BAR CATEGORY, d_b IS DEFINED AS THE DIAMETER OF THE LARGER BAR BEING SPLICED.",
		"3. THE \"CATEGORY 1\" LAP LENGTH SHALL BE USED WHEN THE CLEAR SPACING BETWEEN BARS AT THE SPLICE IS EQUAL TO OR GREATHER THAN 3d_b.",
		"3. THE \"CATEGORY 2\" LAP LENGTH SHALL BE USED WHEN THE CLEAR SPACING BETWEEN BARS AT THE SPLICE IS LESS THAN 3d_b AND GREATHER THAN 2d_b.",
		"3. WHEN THE CLEAR SPACING BETWEEN BATS AT THE SPLICE IS EQUAL TO OR LESS THAN 2d_b, SPLICES SHALL BE STAGGERED SO THAT NO MORE THAN 50% OF BARS ARE SPLICED AT ANY GIVEN LOCATION. REFER TO \"TYPICAL CLEAR SPACING CRITERIA OF LAP SPLICED BARS, STAGGERED SPLICES\" FOR CRITERIA TO DETERMINE CLEAR SPACING \"S\" FOR BARS AT STAGGERED SPLICES.",
		"3. IN CASES WHERE BAR SPACING IS NOT THE SAME AT DIFFERENT COLUMN FACES, THE SMALLER SPACING SHALL BE USED TO DETERMINE THE APPLICABLE SPLICE CATEGORY.",
		"3. ",
		"3. ",
		"4. A BOTTOM BAR IS DEFINED AS ANY BAR THAT DOES NOT HAVE MORE THAN $(12.0u"inch" |> preferred_length) OF FRESH CONCRETE BELOW THE BAR",
		"5. OTHER BARS INCLUDE TOP BARS, FACE BARS, AND ALL OTHER BARS THAT HAVE MORE THAN $(12.0u"inch" |> preferred_length) OF FRESH CONCRETE BELOW THE BAR",
		"6. FOR EPOXY-COATED BARS, MULTIPLY THE TABULATED SPLICE LENGTHS OF BOTTOM BARS BY 1.5 AND TABULATED SPLICE LENGTHS OF OTHER BARS BY 1.3.",
		"7. WHEN LAP SPLICING BARS OF DIFFERENT SIZES, THE LAP LENGTH IS DETERMINED BY THE SAMLLER BUT MAY NOT BE LESS THAN THE \"CLASS A\" SPLICE LENGTH OF THE LARGER BAR.",
		"8. FOR CONCRETE STRENGTHS IN BETWEEN THOSE TABULATED HERE, USE DEVELOPMENT AND LAP SPLICE LENGTHS OF LOWER CONCRETE STRENGTH.",
	]

# ╔═╡ df98734f-adda-44e1-b9d9-7656c1a0dc62
f_y_used = if reinforcement_grade_selected == 40
	40_000.0u"psi"
elseif reinforcement_grade_selected == 60
	60_000.0u"psi"
elseif reinforcement_grade_selected == 75
	75_000.0u"psi"
elseif reinforcement_grade_selected == 80
	80_000.0u"psi"
elseif reinforcement_grade_selected == 100
	100_000.0u"psi"
elseif reinforcement_grade_selected == 0
	f_y_selected * preferred_stress
end |> preferred_stress # if 

# ╔═╡ 5f3ef1ab-3280-41fb-a6b4-53212a664630
md"""
### 25.4.2 Development of deformed bars and deformed wires in tension
"""

# ╔═╡ 87c0ceda-75d3-492b-a071-d2813f892c13
md"""
$br
$br
$br
"""

# ╔═╡ 28d3fe04-6513-4647-8eff-a7b6bb3833bf
md"""
### 25.4.3 Development of standard hooks in tension
"""

# ╔═╡ 8e38639f-5913-49d7-9f86-7b2e9abd49b8
md"""
$br
$br
$br
"""

# ╔═╡ 96414313-cc3d-4e79-b067-534b9ef440f6
md"""
### 25.4.4 Development of headed deformed bars in tension
"""

# ╔═╡ f8e3eb62-ac3a-4645-b341-a9e63c3d8abd
md"""
_missing_
"""

# ╔═╡ 0ff27e34-bc15-49ef-a5fe-a71fffd4acb2
md"""
$br
$br
$br
"""

# ╔═╡ baecef75-a95f-479b-a45e-fae2a7c7df09
md"""
### 25.4.9 Development of deformed bars and deformed wires in compression
"""

# ╔═╡ ff7d932b-44c4-48d0-a06c-8f50ac0718fe
md"""
$br
$br
$br
"""

# ╔═╡ 88cd1122-e048-4606-a1aa-01abf53e3166
md"""
### 25.5.2 Lap splice lengths of deformed bars and deformed wires in tension
"""

# ╔═╡ a9f6ddf2-6114-4ede-8696-35a39adda062
function ℓ_st(ℓ_d, class)
	ℓ_st = if class == "A"
		max(ℓ_d, 12.0u"inch")
	elseif class == "B"
		max(1.3 * ℓ_d, 12.0u"inch")
	end # if

	return ℓ_st
end # ℓ_st

# ╔═╡ c2a51979-4a0c-45dd-a9d7-2af90e80f012
md"""
$br
$br
$br
"""

# ╔═╡ 9285bc03-1746-4c5f-8411-d859273fbc06
md"""
### 25.5.5 Lap splice lengths of deformed bars in compression
"""

# ╔═╡ 30d2fd1a-8025-4e4e-aee4-d712252a2cec
md"""
$br
$br
$br
"""

# ╔═╡ ba66fcf3-34a0-4d6e-9421-852ac6eb8a79
md"""
## Auxiliar lists
"""

# ╔═╡ 00d22203-2ccd-408a-b791-c5a12abb53bf
rebar_list = [
	2;
	3;
	4;
	5;
	6;
	7;
	8;
	9;
	10;
	11;
	14;
	18;
]

# ╔═╡ bc23969d-aaf6-4f06-ad48-0f628c86cb6f
rebar_list_SI = [
	6;
	10;
	13;
	16;
	19;
	22;
	25;
	29;
	32;
	36;
	43;
	57;
]

# ╔═╡ e720a006-63cc-4467-aee7-eb4ac1a72d4b
epoxy_list_en = [
	"Epoxy-coated or zinc and epoxy dual-coated reinforcement with clear cover less than 3d_b or clear spacing less than 6d_b";
	"Epoxy-coated or zinc and epoxy dual-coated reinforcement for all other conditions";
	"Uncoated or zinc-coated (galvanized) reinforcement";
]

# ╔═╡ 8f4babd3-d679-4d9c-8ca8-cc852b10a04b
epoxy_list_es = [
	"Refuerzo con recubrimiento epóxico o zinc y barras con recubrimiento dual de zinc y epóxico on menos de 3d_b de recubrimiento, o separación libre menor que 6d_b";
	"Refuerzo con recubrimiento epóxico o zinc y barras con recubrimiento dual de zinc y epóxico para todas las otras condiciones";
	"Refuerzo sin recubrimiento o refuerzo recubierto con zinc (galvanizado)";
]

# ╔═╡ a7d143b7-c216-478e-ae83-e4ef6125ab08
casting_position_list_en = [
	"More than $(12.0u"inch" |> preferred_length) of fresh concrete placed below horizontal reinforcement";
	"Other";
]

# ╔═╡ 699bae72-e69c-4111-b4d2-eabc635bd75f
casting_position_list_es = [
	"Más de $(300.0u"mm" |> preferred_length) de concreto fresco colocado bajo el refuerzo horizontal";
	"Otra";
]

# ╔═╡ 3d194c62-1450-47a5-89e6-bc3ba42684c9
location_list_en = [
	"For No. 11 and smaller diameter hooked bars: 
	(1) Terminating inside column core with side cover normal to plane of hook ≥ $(2.5u"inch" |> preferred_length), or 
	(2) With side cover normal to plane of hook ≥ 6d_b"; 
	"Other";
]

# ╔═╡ ab0e9d55-595f-4f61-9ceb-b9084f8d3fa0
location_list_es = [
	"Para barras con gancho No. 11 y menores: 
	(1) que terminan dentro del núcleo de la columna con recubrimiento lateral normal al plano del gancho ≥ $(2.5u"inch" |> preferred_length), or 
	(2) con recubrimiento lateral normal al plano del gancho ≥ 6d_b"; 
	"Otros";
]

# ╔═╡ 797936ac-8696-4f40-9b39-1d380d698edd
confining_reinforcement_tension_list_en = [
	"For No. 11 and smaller bars with A_{th} ≥ 0.4 A_{hs} or s ≥ 6 d_b 
	A_{th}: total-cross-sectional area of ties or stirrups confining hooked bars
	A{hs}: total cross-sectional area of hooked or headed bars being developed at a critical section";
	"Other";
]

# ╔═╡ cf93d9d1-7373-401d-9ca7-962b48fb96a9
confining_reinforcement_tension_list_es = [
	"Para barras No. 11 y menores con A_{th} ≥ 0.4 A_{hs} or s ≥ 6 d_b 
	A_{th}: área total de la sección de los estribos que confinan las barras con gancho
	A{hs}: área total de las barras con gancho o cabeza que se desarrollan en la sección crítica";
	"Otros";
]

# ╔═╡ fdda1c3c-3721-4f9e-b032-5ecd4baf9928
confining_case_list_en = [
	"Clear spacing of bars or wires being developed or lap spliced not less than d_b, clear cover at least d_b, and stirrups or ties throughout l_d not less than the Code minimum
	or 
	Clear spaing of bars or wires being developed or lap spliced at least 2d_b and clear cover at least d_b"; 
	"Other cases";
]

# ╔═╡ 9cfb37cf-2e90-4ddc-87f2-3adfff4ffe07
confining_case_list_es = [
	"Espaciamiento libre entre barras o alambres que están desarrollando o empalmando por tralape no menor que d_b, recubrimiento libre al menos d_b, y no menos estribos a lo largo de l_d que el mínimo del Reglamento
	o
	espaciamiento libre entre barras o alambres que están siendo desarrollados o empalmados por traslape no menos que al menos 2d_b y recubrimiento libre al menos que d_b"; 
	"Otros casos";
]

# ╔═╡ 38110d01-a1cf-4142-bad6-b1f54c2707d4
confining_reinforcement_compression_list_en = [
	"Reinforcement enclosed within (1), (2), (3), or (4):
		(1) a spiral
		(2) a circular continuously wound tie with d_b ≥ $(1/4*u"inch" |> preferred_length) and pitch $(4.0u"inch" |> preferred_length).
		(3) No. 4 bar or D20 wire ties in accordance with 25.7.2 spaced ≤ $(4.0u"inch" |> preferred_length) on center
		(4) hoops in accordance with 25.7.4 spaced ≤ $(4.0u"inch" |> preferred_length) on center
	";
	"Other";
]

# ╔═╡ 4b179948-2742-4b59-9507-62ba7f76e28d
confining_reinforcement_compression_list_es = [
	"Refuerzo encerrado dentro de (1), (2), (3), or (4):
		(1) una espiral.
		(2) un estribo circular continuo con d_b ≥ $(1/4*u"inch" |> preferred_length) y paso $(4.0u"inch" |> preferred_length).
		(3) Estribo de barra No. 4 or alambre D20 de acuerdo con 25.7.2 espaciado ≤ $(4.0u"inch" |> preferred_length) centro a centro.
		(4) estribos cerrados de confinamiento de acuerdo con 25.7.4 y espaciadas a distancias ≤ $(4.0u"inch" |> preferred_length), centro a centro.
	";
	"Otra";
]

# ╔═╡ 1be46ba1-ddc7-4657-b264-6a170968a0fd
# ENGLISH
if language == "en"
	epoxy_list = epoxy_list_en
	casting_position_list = casting_position_list_en
	location_list = location_list_en
	confining_reinforcement_tension_list = confining_reinforcement_tension_list_en
	confining_case_list = confining_case_list_en
	confining_reinforcement_compression_list = confining_reinforcement_compression_list_en

# SPANISH
elseif language == "es"
	epoxy_list = epoxy_list_es
	casting_position_list = casting_position_list_es
	location_list = location_list_es
	confining_reinforcement_tension_list = confining_reinforcement_tension_list_es
	confining_case_list = confining_case_list_es
	confining_reinforcement_compression_list = confining_reinforcement_compression_list_es
	
end # if

# ╔═╡ 8d089fd6-82e9-4e23-ae4c-8eeb832734b1
let
reset_selected_to_defaults; 
	
text = Dict(
	"en" => md"Epoxy type:",
	"es" => md"Tipo de epóxico:",
);
	
md"""
 $(text[language]) 
 $(
	@bind epoxy_type_selected Select(
		epoxy_list, 
		default=epoxy_list[3]
	)
)
"""
end

# ╔═╡ 4f22d62b-baef-4732-8dd7-5648bad8f5e5
let
reset_selected_to_defaults; 
	
text = Dict(
	"en" => md"Confining reinforcement for tension:",
	"es" => md"Confinamiento del refuerzo a tensión:",
);
	
md"""
 $(text[language]) 
 $(
	@bind confining_reinforcement_tension_selected Select(
		confining_reinforcement_tension_list, 
		default=confining_reinforcement_tension_list[1]
	)
)
"""
end

# ╔═╡ b847e1b1-008e-4caa-b8ae-7cb37b5e73a3
let
reset_selected_to_defaults; 
	
text = Dict(
	"en" => md"Location of reinforcement:",
	"es" => md"Ubicación del refuerzo:",
);
	
md"""
 $(text[language]) 
 $(
	@bind location_selected Select(
		location_list, 
		default=location_list[1]
	)
)
"""
end

# ╔═╡ f547952e-feed-45b1-ad69-25d5b5d289f4
let
reset_selected_to_defaults; 
	
text = Dict(
	"en" => md"Confining case:",
	"es" => md"Caso de confinamiento:",
);
	
md"""
 $(text[language]) 
 $(
	@bind confining_case_selected Select(
		confining_case_list, 
		default=confining_case_list[1]
	)
 )
"""
end

# ╔═╡ fc68a3d0-656d-4efc-9239-11636d2f6500
let
reset_selected_to_defaults; 
	
text = Dict(
	"en" => md"Confining reinforcement for compression:",
	"es" => md"Confinamiento del refuerzo a compresión:",
);
	
md"""
 $(text[language]) 
 $(
	@bind confining_reinforcement_compression_selected Select(
		confining_reinforcement_compression_list, 
		default=confining_reinforcement_compression_list[2]
	)
)

"""
end

# ╔═╡ b6bb7fdd-aecd-41a0-934a-2981155355d5
md"""
# Auxiliary functions
"""

# ╔═╡ 3d5a0e0f-e596-4112-8b29-29a965bf7e79
md"""
##### Packages 
Packages loaded only to the notebook
"""

# ╔═╡ 1934ea7f-da27-457d-90d9-539643a4f410
html"<br><br><br>"

# ╔═╡ 7ad9475c-c627-46c6-9a3c-dee1948813df
md"""
##### Units 
Adding units to notebook
"""

# ╔═╡ 94a1af2f-8d24-45b0-8698-953d274b7dee
Unitful.register(MyUnits)

# ╔═╡ f05e9c74-217d-4e9b-9c81-dbc532955c32
Markdown.html(io::IO, ls::LaTeXString) = 
		Markdown.html(io, Markdown.LaTeX(
			repr(MIME"text/latex"(), ls)
		))

# ╔═╡ 2e218d89-a015-42a7-b294-6eefc8645b8a
Markdown.htmlinline(io::IO, ls::LaTeXString) = 
		Markdown.htmlinline(io, Markdown.LaTeX(
			repr(MIME"text/latex"(), ls)
		))

# ╔═╡ 2d8481ab-752a-49c2-91c6-8066509e4f83
Latexify.set_default(
	# fmt = "%.2f", 
	# convert_unicode = false,
	permode=:slash
)

# ╔═╡ 6221e2b7-bd96-4319-b484-71841d655e40
html"<br><br><br>"

# ╔═╡ b2dc96b9-6bcd-444a-9529-b238264a45d1
md"""
##### Customize Table of Contents
"""

# ╔═╡ 23bef496-953f-4c5f-89c8-1ac5cdea05be
@htl("""
$(ExtendedTableOfContents(;
	# title = "",
	# indent = true,
	depth = 4,
	aside = true,
	# include_definitions = false,
	hide_preamble = false,
	# force_hide_enabled = true,
))
<script>
	const cell = currentScript.closest('pluto-cell')
	cell.toggleAttribute('always-show',false)
	cell.toggleAttribute('always-show-output',true)
</script>
""")

# ╔═╡ db44a838-7818-4798-a9be-1c1b9f9d9868
html"<br><br><br>"

# ╔═╡ acaefb97-3439-4a62-86ed-daf76988fa04
md"""
##### Misc functions
"""

# ╔═╡ 6c215c39-ecb1-4ece-af5b-6614311ae7e1
# This simplifies applying custom css to cell outputs using the emtion JS library
function apply_css(css; class = nothing)
	to_js(x) = HypertextLiteral.JavaScript(x)
	function apply(item)
		content = @htl("
			<div class='$class'>
				$item
			</div>
		")
		isnothing(css) && return content
		@htl("""
			$content
			<script>
				const { css } = await import("https://esm.sh/@emotion/css")
				const item = currentScript.previousElementSibling
				const className = css`$(to_js(css))`
				item.classList.add(className)
			</script>
		""")
	end
end

# ╔═╡ fb20596d-ac09-4ff5-bc0c-2833e61ccc37
"""
Removes the function argument list from the latex equation,
so equations are shorter and better match the source text.
"""
function remove_arguments(s::LaTeXString)
    r = r"\\left\(.*?\\right\)|\(\)"
    return LaTeXString(replace(s, r=>"", count=1))
end

# ╔═╡ 9ee27fcb-f472-45da-95f1-7defe75b6b50
Markdown.parse("""
**Size** 

$(
remove_arguments(
	@latexrun Ψs_(rebar_size) = if rebar_size ≥ 7
		1.0
	elseif rebar_size ≤ 6
		0.8
	end # if
)
)
""")

# ╔═╡ 5df76aa2-aacc-4ffa-8a72-4bba26e690a4
Markdown.parse("""
**Casting position** 

$(
remove_arguments(
	@latexrun Ψt_(casting_position) = if casting_position == $(casting_position_list[1])
		1.3
	elseif casting_position == $(casting_position_list[2])
		1.0
	end # if
)
)
""")

# ╔═╡ ccb73a9f-1bc1-4293-ac4f-161106411c94
Markdown.parse("""
**Epoxy** 

$(
remove_arguments(
	# Epoxy factor
	@latexrun Ψe_(epoxy_type) = if epoxy_type == $(epoxy_list[1])
		1.5
	elseif epoxy_type == $(epoxy_list[2])
		1.2
	elseif epoxy_type == $(epoxy_list[3])
		1.0
	end # if
)
)
""")

# ╔═╡ 1f16805b-edf3-47f1-8bdb-b10fd6344131
Markdown.parse("""
##### 25.4.2.5 Modification factors for development of hooked bars in tension.

**Confining reinforcement** 

$(
remove_arguments(
	# Confining reinforcement
	@latexrun Ψr_(confining_reinforcement) = if confining_reinforcement == $(confining_reinforcement_tension_list[1])
		1.0
	elseif confining_reinforcement == $(confining_reinforcement_tension_list[2])
		1.6
	end # if
)
)
""")

# ╔═╡ 732337cf-141d-4694-a839-b6dbf33149ba
Markdown.parse("""
**Location** 

$(
remove_arguments(
	# Location
	@latexrun Ψo_(location) = if location == $(location_list[1])
		1.0
	elseif location == $(location_list[2])
		1.25
	end # if
)
)
""")

# ╔═╡ 7ad6e59b-cb77-4c90-8f9c-c43f227095f5
"""
Removes the function 'wrong' printing of units in latex equation.
Example: `mathrm{@u}_{str}left( psi right)` to ` psi `
"""
function remove_unitstring(s::LaTeXString)
    r = r"\\cdot \\mathrm{@u}_{str}\\left\( .*? \\right\)"
    unit = r"(?<= \\mathrm{@u}_{str}\\left\( )(.*?)(?= \\right\))"
	
	matched_units = collect(eachmatch(unit,s))
	for i=eachindex(matched_units)
		units = matched_units[i].match
		s = LaTeXString(replace(s, r=>units, count=1))
	end
	
	return s
end

# ╔═╡ 6c4aec09-d71f-4328-bb32-fc5408809086
remove_unitstring(remove_arguments(
	@latexrun db_(rebar_size) = rebar_size * (1/8) * 1.0u"inch"
))

# ╔═╡ 084a1034-e187-4ce0-ba7b-289af1a0c181
function ℓ_ext_development_90degrees(rebar_size)
	d_b = db_(rebar_size)
		
	ℓ_ext = 12.0 * d_b

	if rebar_size ≤ 2
		D = 4.0 * d_b
		
	elseif 3 ≤ rebar_size ≤ 8
		D = 6.0 * d_b
		
	elseif 9 ≤ rebar_size ≤ 11
		D = 8.0 * d_b
		
	elseif 14 ≤ rebar_size ≤ 18
		D = 10.0 * d_b
		
	end # if

	return D, ℓ_ext
end # ℓ_ext_stirrups

# ╔═╡ d9208986-cfe8-46b1-bdec-51ae67db529e
function ℓ_ext_development_180degrees(rebar_size)
	d_b = db_(rebar_size)
		
	ℓ_ext = max(2.5u"inch", 4.0 * d_b)

	if rebar_size ≤ 2
		D = 4.0 * d_b
		
	elseif 3 ≤ rebar_size ≤ 8
		D = 6.0 * d_b
		
	elseif 9 ≤ rebar_size ≤ 11
		D = 8.0 * d_b
		
	elseif 14 ≤ rebar_size ≤ 18
		D = 10.0 * d_b
		
	end # if

	return D, ℓ_ext
end # ℓ_ext_stirrups

# ╔═╡ cf962767-3d1b-4cf8-a9c9-94082b7dafcb
let
	# Print in a table all straight extensions

	# rebar_list = rebar_list
	D = zeros(typeof(1.0u"inch"), length(rebar_list))
	ℓ_ext_90 = zeros(typeof(1.0u"inch"), length(rebar_list))
	ℓ_ext_180 = zeros(typeof(1.0u"inch"), length(rebar_list))
	for i in eachindex(rebar_list)
		D[i] = ℓ_ext_development_90degrees(rebar_list[i])[1] 
		ℓ_ext_90[i] = ℓ_ext_development_90degrees(rebar_list[i])[2]
		ℓ_ext_180[i] = ℓ_ext_development_180degrees(rebar_list[i])[2]
	end # for

	# Bar size
	bar_size_header = [
		"Bar Size" "Bar Size";
		"d_b" "d_b";
		"d_b" "d_b";
	]
	bar_size_units = [
		"1/8in" "mm";
	]
	bar_size = hcat(
		"#" .* string.(rebar_list), 
		"#" .* string.(rebar_list), 
	)

	# Straigh extension
	development_length_tension_header = [
		"Bend diameter" "Straight extension" "Straight extension";
		"D" 			"ℓ_ext" "ℓ_ext";
		"D" "90°" "180°";
	]
	development_length_tension_units = [
		preferred_length preferred_length preferred_length;
	]
	development_length_tension = hcat(	
		(D .|> preferred_length) ./ preferred_length, 
		(ℓ_ext_90 .|> preferred_length) ./ preferred_length,
		(ℓ_ext_180 .|> preferred_length) ./ preferred_length,
	)

	# Converting to CELLS
	bar_size_cells = [
		Cell.(bar_size_header, bold = true, merge = true, valign = :center);
		Cell.(bar_size_units, italic = true, merge = false, valign = :center);
		Cell.(bar_size, bold = true, merge = false, valign = :center);
	]
	development_length_tension_cells = [
		Cell.(development_length_tension_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_tension_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_tension, bold = true, merge = false, valign = :center);
	]

	table = Table(
		header = 4,
		# footer = 18,
		# footnotes = notes,
		# linebreak_footnotes = false,
		# rowgaps = [8 => 5.0, 11 => 5.0, 14 => 5.0],
		# colgaps = [2 => 10.0, #=3 => 10.0, 4 => 0.0=#],
		hcat(
		    bar_size_cells,
			development_length_tension_cells,
			# splice_tension_cells,
			# development_length_compression_cells,
			# splice_compression_cells,
			# notes
		),
	    round_digits = 3,
    	round_mode = :sigdigits, # :auto :digits :sigdigits
		trailing_zeros = false,
	)
	md"""
	### Table 25.3.1 - Standard hook geometry for development of deformed bars in tension
	$(table)
	"""
end

# ╔═╡ 2298372c-ffe5-4820-b0c3-1903dbca929a
function ℓ_ext_stirrups_90degrees(rebar_size)
	d_b = db_(rebar_size)
	
	if rebar_size ≤ 2
		ℓ_ext = 8.0 * d_b
		D = 4.0 * d_b
		
	elseif 3 ≤ rebar_size ≤ 5
		ℓ_ext = max(3.0u"inch", 6.0 * d_b)
		D = 4.0 * d_b
		
	elseif 6 ≤ rebar_size ≤ 8
		ℓ_ext = 12.0 * d_b
		D = 6.0 * d_b
		
	end # if

	return D, ℓ_ext
end # ℓ_ext_stirrups

# ╔═╡ 05afdf93-e0f9-43b8-bd1b-4e9951ab6e00
function ℓ_ext_stirrups_135degrees(rebar_size)
	d_b = db_(rebar_size)
	
	if rebar_size ≤ 2
		ℓ_ext = 8.0 * d_b
		D = 4.0 * d_b
		
	elseif 3 ≤ rebar_size ≤ 5
		ℓ_ext = max(3.0u"inch", 6.0 * d_b)
		D = 4.0 * d_b
		
	elseif 6 ≤ rebar_size ≤ 8
		ℓ_ext = max(3.0u"inch", 6.0 * d_b)
		D = 6.0 * d_b
		
	end # if

	return D, ℓ_ext
end # ℓ_ext_stirrups

# ╔═╡ 8121a598-bbfc-4a60-b7a8-5e04b9f3079b
function ℓ_ext_stirrups_180degrees(rebar_size)
	d_b = db_(rebar_size)
	
	ℓ_ext = max(2.5u"inch", 4.0 * d_b)
	
	if rebar_size ≤ 2
		D = 4.0 * d_b
		
	elseif 3 ≤ rebar_size ≤ 5
		D = 4.0 * d_b
		
	elseif 6 ≤ rebar_size ≤ 8
		D = 6.0 * d_b
		
	end # if

	return D, ℓ_ext
end # ℓ_ext_stirrups

# ╔═╡ e5c956a1-7803-4bf9-9663-f39c126e2522
let
	# Print in a table all straight extensions

	rebar_list_stirrups = rebar_list[1:3]
	D = zeros(typeof(1.0u"inch"), length(rebar_list_stirrups))
	ℓ_ext_90 = zeros(typeof(1.0u"inch"), length(rebar_list_stirrups))
	ℓ_ext_135 = zeros(typeof(1.0u"inch"), length(rebar_list_stirrups))
	ℓ_ext_180 = zeros(typeof(1.0u"inch"), length(rebar_list_stirrups))
	for i in eachindex(rebar_list_stirrups)
		D[i] = ℓ_ext_stirrups_135degrees(rebar_list_stirrups[i])[1] 
		ℓ_ext_90[i] = ℓ_ext_stirrups_90degrees(rebar_list_stirrups[i])[2]
		ℓ_ext_135[i] = ℓ_ext_stirrups_135degrees(rebar_list_stirrups[i])[2]
		ℓ_ext_180[i] = ℓ_ext_stirrups_180degrees(rebar_list_stirrups[i])[2]
	end # for

	# Bar size
	bar_size_header = [
		"Bar Size" "Bar Size";
		"d_b" "d_b";
		"d_b" "d_b";
	]
	bar_size_units = [
		"1/8 in" "mm";
	]
	bar_size = hcat(
		"#" .* string.(rebar_list_stirrups), 
		"#" .* string.(rebar_list_stirrups), 
	)

	# Straigh extension
	development_length_tension_header = [
		"Bend diameter" "Straight extension" "Straight extension" "Straight extension";
		"D" 			"ℓ_ext" "ℓ_ext" "ℓ_ext";
		"D" "90°" "135°" "180°";
	]
	development_length_tension_units = [
		preferred_length preferred_length preferred_length preferred_length;
	]
	development_length_tension = hcat(	
		(D .|> preferred_length) ./ preferred_length, 
		(ℓ_ext_90 .|> preferred_length) ./ preferred_length,
		(ℓ_ext_135 .|> preferred_length) ./ preferred_length,
		(ℓ_ext_180 .|> preferred_length) ./ preferred_length,
	)

	# Converting to CELLS
	bar_size_cells = [
		Cell.(bar_size_header, bold = true, merge = true, valign = :center);
		Cell.(bar_size_units, italic = true, merge = false, valign = :center);
		Cell.(bar_size, bold = true, merge = false, valign = :center);
	]
	development_length_tension_cells = [
		Cell.(development_length_tension_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_tension_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_tension, bold = true, merge = false, valign = :center);
	]

	table = Table(
		header = 4,
		# footer = 18,
		# footnotes = notes,
		# linebreak_footnotes = false,
		# rowgaps = [8 => 5.0, 11 => 5.0, 14 => 5.0],
		# colgaps = [2 => 10.0, #=3 => 10.0, 4 => 0.0=#],
		hcat(
		    bar_size_cells,
			development_length_tension_cells,
			# splice_tension_cells,
			# development_length_compression_cells,
			# splice_compression_cells,
			# notes
		),
	    round_digits = 3,
    	round_mode = :sigdigits, # :auto :digits :sigdigits
		trailing_zeros = false,
	)
	md"""
	### Table 25.3.2 - Minimum inside bend diameters and standard hook geometry for stirrups, ties, and hoops
	$(table)
	"""
end

# ╔═╡ 20a657f5-2cdc-46b6-8919-389f7ee812b0
function ℓ_sc(f_y, f_c, rebar_size, ℓ_st=1000.0u"inch")
	d_b = db_(rebar_size)
	
	ℓ_sc = if f_y ≤ 60_000.0u"psi"
		max(
			12.0u"inch",
			0.0005u"1.0/psi" * f_y * d_b,
		)
	
	elseif 60_000.0u"psi" ≤ f_y ≤ 80_000.0u"psi"
		max(
			12.0u"inch",
			(0.0009u"1.0/psi" * f_y - 24.0) * d_b,
		)
		
	elseif f_y ≥ 80_000.0u"psi"
		max(
			(0.0009u"1.0/psi" * f_y - 24.0) * d_b,
			ℓ_st,
		)
		
	end # if

	ℓ_sc = f_c < 3_000u"psi" ? (1.0 + 1/3) * ℓ_sc : ℓ_sc
	
	return ℓ_sc
end # ℓ_sc

# ╔═╡ fd5d62c7-491e-4a3e-ad50-f31e5e1f81fd
remove_unitstring(remove_arguments(
	@latexrun λ_(lightweight_concrete) = if lightweight_concrete == true
		0.75
	elseif lightweight_concrete == false
		1.00
	end # if
))

# ╔═╡ 9345cc82-e951-4eea-91bc-3cf6bd503327
Markdown.parse("""
##### 25.4.9.1 Development length `` ℓ_{dc} `` for deformed bars and deformed wires in compression shall be: 

$(
remove_arguments(
@latexrun function ℓ_dc(
	rebar_size, 
	f_c, 
	f_y, 
	lightweight_concrete, 
	confining_reinforcement, 
)
	
	d_b = db_(rebar_size)

	# Lightweight factor
	λ = λ_(lightweight_concrete)

	# Confining reinforcement
	Ψ_r = if confining_reinforcement == confining_reinforcement_compression_list[1]
		0.75
	elseif confining_reinforcement == confining_reinforcement_compression_list[2]
		1.0
	end # if

	# Develpment length
	ℓ_dc = max(
		8.0u"inch",
		0.0003u"inch^2 / lbf" * f_y * Ψ_r * d_b,
		(1/50) * (f_y * Ψ_r / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * d_b
	) |> u"inch"

	return ℓ_dc
end # ℓ_dc
)
)


""")

# ╔═╡ 48f8a053-29bb-422f-b203-c51b6ba1eab9
Markdown.parse("""
##### 25.4.1.4. The values of `` \\sqrt{f'_c} `` used to calculate development length shall not exceed `` $(100.0u"psi") ``. 

$(
remove_unitstring(
# remove_arguments(
	# @latexrun f_cmax = (100.0u"lbf^0.5 / inch")^2
	@latexdefine f_cmax = 100.0^2 * u"psi"
# )
)
)
""")

# ╔═╡ 8ef04446-1dbd-480d-b49a-a79ba9e8f015
f_c_used = min(f_cmax, f_c_selected * preferred_stress) |> preferred_stress 

# ╔═╡ 1c9c182a-0627-4d75-802f-2677cc26fbdb
Markdown.parse("""
##### 25.4.2.5 Modification factors for development of deformed bars and deformed wires in tension.

**Reinforcement grade** 

$(
remove_unitstring(remove_arguments(
	@latexrun Ψg_(f_y) = if f_y ≤ 60_000.0u"psi"
		1.0
	elseif 60_000u"psi" < f_y ≤ 80_000.0u"psi"
		1.15
	elseif f_y > 80_000.0u"psi"
		1.3
	end # if
))
)
""")

# ╔═╡ 66d2c12a-2885-4c03-8da5-3d7ad6dee360
Markdown.parse("""
##### 25.4.2.4 For deformed bars or deformed wires, `` ℓ_d `` shall be calculated by: 

$(
remove_arguments(
@latexrun function ℓ_d(
	rebar_size, 
	f_c, 
	confining_case,
	f_y, 
	lightweight_concrete, 
	epoxy_type, 
	casting_position, 
)
	d_b = db_(rebar_size)

	# Lightweight factor
	λ = λ_(lightweight_concrete)

	# Reinforcement grade factor
	Ψ_g = Ψg_(f_y)

	# Epoxy factor
	Ψ_e = Ψe_(epoxy_type)

	# Rebar size factor
	Ψ_s = Ψs_(rebar_size)

	# Casting position factor
	Ψ_t = Ψt_(casting_position)

	ΨtΨe = min(1.7, Ψ_t * Ψ_e)
	
	# Develpment length
	ℓ_d = max(
		12.0u"inch",
		
		if confining_case == confining_case_list[1]
			(3/40) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (ΨtΨe * Ψ_s * Ψ_g / (1.5)) * d_b # 1.5 = c_b + K_tr / d_b
		elseif confining_case == confining_case_list[2]
			(3/40) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (ΨtΨe * Ψ_s * Ψ_g / (1.0)) * d_b # 1.0 = c_b + K_tr / d_b
		end # if
	)

	return ℓ_d
end # ℓ_d
)
)


""")

# ╔═╡ 47f6d488-5c99-4635-b3de-0db1c0bd25f8
Markdown.parse("""
**Location** 

$(
remove_unitstring(remove_arguments(
	@latexrun Ψc_(f_c) = if f_c < 6000.0u"psi"
		f_c/15_000.0u"psi" + 0.6
	elseif f_c ≥ 6000.0u"psi"
		1.0
	end # if
))
)
""")

# ╔═╡ 5f702941-0371-4148-827b-8922999a9ee3
Markdown.parse("""
##### 25.4.2.4 Development length `` ℓ_{dh} `` for deformed bars in tension terminating in a standard hook shall be: 

$(
remove_arguments(
@latexrun function ℓ_dh(
	rebar_size, 
	f_c, 
	f_y, 
	lightweight_concrete, 
	epoxy_type, 
	confining_reinforcement, 
	location,
)
	d_b = db_(rebar_size)

	# Lightweight factor
	λ = λ_(lightweight_concrete)

	# Epoxy factor
	Ψ_e = if epoxy_type == epoxy_list[1] || epoxy_type == epoxy_list[2]
		1.2
	elseif epoxy_type == epoxy_list[3]
		1.0
	end # if

	# Confining reinforcement
	Ψ_r = Ψr_(confining_reinforcement)

	# Location
	Ψ_o = Ψo_(location)

	# Concrete strength factor
	Ψ_c = Ψc_(f_c)

	# Develpment length
	ℓ_dh = max(
		6.0u"inch",
		8 * d_b,
		(1/50) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (Ψ_e * Ψ_r * Ψ_o * Ψ_c) * (d_b^(1.5) / 1.0u"inch^0.5")
	)

	return ℓ_dh
end # ℓ_dh
)
)


""")

# ╔═╡ 78784a0f-343f-468d-a319-67dd0739acf7
begin
	# Calculate the development length in tension for top, bot and hook
	ℓ_d_table_top_inch = ℓ_d.(
		rebar_list, 
		f_c_used, 
		confining_case_selected,
		f_y_used, 
		lightweight_concrete_selected, 
		epoxy_type_selected, 
		casting_position_list[1], 
	)
	
	ℓ_d_table_bot_inch = ℓ_d.(
		rebar_list, 
		f_c_used, 
		confining_case_selected,
		f_y_used, 
		lightweight_concrete_selected, 
		epoxy_type_selected, 
		casting_position_list[2], 
	)
	ℓ_d_table_hook_inch = ℓ_dh.(
		rebar_list, 
		f_c_used, 
		f_y_used, 
		lightweight_concrete_selected, 
		epoxy_type_selected, 
		confining_reinforcement_tension_selected, 
		location_selected,
	)

	ℓ_dc_table_inch = ℓ_dc.(
		rebar_list, 
		f_c_used, 
		f_y_used, 
		lightweight_concrete_selected, 
		confining_reinforcement_compression_selected, 
	)
	
	# Splices in TENSION
	ℓ_st_table_top_classA_inch = ℓ_st.(ℓ_d_table_top_inch, "A")
	ℓ_st_table_bot_classA_inch = ℓ_st.(ℓ_d_table_bot_inch, "A")
	ℓ_st_table_top_classB_inch = ℓ_st.(ℓ_d_table_top_inch, "B")
	ℓ_st_table_bot_classB_inch = ℓ_st.(ℓ_d_table_bot_inch, "B")

	# eliminating the #14 and #18 splices as it is not permitted
	ℓ_st_table_top_classA_inch[end-1:end] .= 0.0u"inch"
	ℓ_st_table_bot_classA_inch[end-1:end] .= 0.0u"inch"
	ℓ_st_table_top_classB_inch[end-1:end] .= 0.0u"inch"
	ℓ_st_table_bot_classB_inch[end-1:end] .= 0.0u"inch"

	
	# # Splices in COMPRESSION
	ℓ_sc_table_inch = ℓ_sc.(f_y_used, f_c_used, rebar_list)
	
	ℓ_sc_table_top_classA_inch = ℓ_sc.(f_y_used, f_c_used, rebar_list, ℓ_st_table_top_classA_inch)
	ℓ_sc_table_bot_classA_inch = ℓ_sc.(f_y_used, f_c_used, rebar_list, ℓ_st_table_bot_classA_inch)
	ℓ_sc_table_top_classB_inch = ℓ_sc.(f_y_used, f_c_used, rebar_list, ℓ_st_table_top_classB_inch)
	ℓ_sc_table_bot_classB_inch = ℓ_sc.(f_y_used, f_c_used, rebar_list, ℓ_st_table_bot_classB_inch)

	# # eliminating the #14 and #18 splices as it is not permitted
	ℓ_sc_table_inch[end-1:end] .= 0.0u"inch"
	
	ℓ_sc_table_top_classA_inch[end-1:end] .= 0.0u"inch"
	ℓ_sc_table_bot_classA_inch[end-1:end] .= 0.0u"inch"
	ℓ_sc_table_top_classB_inch[end-1:end] .= 0.0u"inch"
	ℓ_sc_table_bot_classB_inch[end-1:end] .= 0.0u"inch"


	
	# Round up the length and chaning to preferred Units system
	ℓ_d_table_top = ceil.(preferred_length, ℓ_d_table_top_inch)
	ℓ_d_table_bot = ceil.(preferred_length, ℓ_d_table_bot_inch)
	ℓ_d_table_hook = ceil.(preferred_length, ℓ_d_table_hook_inch)
	ℓ_dc_table = ceil.(preferred_length, ℓ_dc_table_inch)

	ℓ_st_table_top_classA = ceil.(preferred_length, ℓ_st_table_top_classA_inch)
	ℓ_st_table_bot_classA = ceil.(preferred_length, ℓ_st_table_bot_classA_inch)
	ℓ_st_table_top_classB = ceil.(preferred_length, ℓ_st_table_top_classB_inch)
	ℓ_st_table_bot_classB = ceil.(preferred_length, ℓ_st_table_bot_classB_inch)

	ℓ_sc_table = ceil.(preferred_length, ℓ_sc_table_inch)
	
	ℓ_sc_table_top_classA = ceil.(preferred_length, ℓ_sc_table_top_classA_inch)
	ℓ_sc_table_bot_classA = ceil.(preferred_length, ℓ_sc_table_bot_classA_inch)
	ℓ_sc_table_top_classB = ceil.(preferred_length, ℓ_sc_table_top_classB_inch)
	ℓ_sc_table_bot_classB = ceil.(preferred_length, ℓ_sc_table_bot_classB_inch)
end; "Calcs"

# ╔═╡ c6c9ea3e-1088-4fd7-9225-2ccb6988a45b
let
	# Print in a table all development lengths

	# Bar size
	bar_size_header = [
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
	]
	bar_size_units = [
		"1/8in" "mm";
	]
	bar_size = hcat(
		"#" .* string.(rebar_list), 
		"#" .* string.(rebar_list_SI), 
	)

	# Development length in TENSION
	development_length_tension_header = [
		"Tension" 		"Tension" 		"Tension";
		"Development" 	"Development" 	"Development";
		"Development" 	"Development" 	"Development";
		"Other, ℓ_d" 		"Bot, ℓ_d" 		"Hook, ℓ_dh";
	]
	development_length_tension_units = [
		preferred_length preferred_length preferred_length;
	]
	development_length_tension = hcat(	
		ℓ_d_table_top  ./ preferred_length, 
		ℓ_d_table_bot  ./ preferred_length,
		ℓ_d_table_hook ./ preferred_length,

	)

	# Splice in TENSION
	splice_tension_header = [
		"Tension" 	"Tension" 	"Tension" 	"Tension";
		"Splice, ℓ_st" 	"Splice, ℓ_st" 	"Splice, ℓ_st" 	"Splice, ℓ_st";
		"Class A" 	"Class A" 	"Class B" 	"Class B";
		"Other" 		"Bot" 		"Other" 		"Bot";
	]
	splice_tension_units = [
		preferred_length preferred_length preferred_length preferred_length;
	]
	splice_tension = hcat(
		ℓ_st_table_top_classA  ./ preferred_length, 
		ℓ_st_table_bot_classA  ./ preferred_length,
		ℓ_st_table_top_classB  ./ preferred_length, 
		ℓ_st_table_bot_classB  ./ preferred_length,
	)

	# Development length in COMPRESSION
	development_length_compression_header = [
		"Compression";
		"Development, ℓ_dc";
		"Development, ℓ_dc";
		"Development, ℓ_dc";
	]
	development_length_compression_units = [
		preferred_length
	]
	development_length_compression = hcat(
		ℓ_dc_table ./ preferred_length,
	)

	# Splice in COMPRESSION
	if f_y_used ≤ 80_000.0u"psi"
		splice_compression_header = [
			"Compression";
			"Splice, ℓ_sc";
			"Splice, ℓ_sc";
			"Splice, ℓ_sc";
		]
		splice_compression_units = [
			preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table  ./ preferred_length, 
		)
		
	else
		splice_compression_header = [
			"Compression" 	"Compression" 	"Compression" 	"Compression";
			"Splice, ℓ_sc" 		"Splice, ℓ_sc" 		"Splice, ℓ_sc" 		"Splice, ℓ_sc";
			"Class A" 		"Class A" 		"Class B" 		"Class B";
			"Other" 			"Bot" 			"Other" 			"Bot";
		]
		splice_compression_units = [
			preferred_length preferred_length preferred_length preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table_top_classA  ./ preferred_length, 
			ℓ_sc_table_bot_classA  ./ preferred_length,
			ℓ_sc_table_top_classB  ./ preferred_length, 
			ℓ_sc_table_bot_classB  ./ preferred_length,
		)
	end # if



	# Converting to CELLS
	bar_size_cells = [
		Cell.(bar_size_header, bold = true, merge = true, valign = :center);
		Cell.(bar_size_units, italic = true, merge = false, valign = :center);
		Cell.(bar_size, bold = true, merge = false, valign = :center);
	]
	development_length_tension_cells = [
		Cell.(development_length_tension_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_tension_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_tension, bold = true, merge = false, valign = :center);
	]

	splice_tension_cells = [
		Cell.(splice_tension_header, bold = true, merge = true, valign = :center);
		Cell.(splice_tension_units, italic = true, merge = false, valign = :center);
		Cell.(splice_tension, bold = true, merge = false, valign = :center);
	]

	development_length_compression_cells = [
		Cell.(development_length_compression_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_compression_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_compression, bold = true, merge = false, valign = :center);
	]

	splice_compression_cells = [
		Cell.(splice_compression_header, bold = true, merge = true, valign = :center);
		Cell.(splice_compression_units, italic = true, merge = false, valign = :center);
		Cell.(splice_compression, bold = true, merge = false, valign = :center);
	]

	Table(
		header = 5,
		footer = 18,
		footnotes = notes,
		# linebreak_footnotes = false,
		rowgaps = [8 => 5.0, 11 => 5.0, 14 => 5.0],
		colgaps = [2 => 10.0, #=3 => 10.0, 4 => 0.0=#],
		hcat(
		    bar_size_cells,
			development_length_tension_cells,
			splice_tension_cells,
			development_length_compression_cells,
			splice_compression_cells,
			# notes
		),
	    round_digits = 3,
    	round_mode = :sigdigits, # :auto :digits :sigdigits
		trailing_zeros = false,
	)
end

# ╔═╡ 29f7f3ac-5aa4-4613-875e-cc5b3064cab4
let
	# Print in a table all development lengths

	# Bar size
	bar_size_header = [
		"Tamaño de varilla" "Tamaño de varilla";
		"Tamaño de varilla" "Tamaño de varilla";
		"Tamaño de varilla" "Tamaño de varilla";
		"Tamaño de varilla" "Tamaño de varilla";
	]
	bar_size_units = [
		"1/8in" "mm";
	]
	bar_size = hcat(
		"#" .* string.(rebar_list), 
		"#" .* string.(rebar_list_SI), 
	)

	# Development length in TENSION
	development_length_tension_header = [
		"Tensión" 		"Tensión" 		"Tensión";
		"Longitud de desarrollo" 	"Longitud de desarrollo" 	"Longitud de desarrollo";
		"Longitud de desarrollo" 	"Longitud de desarrollo" 	"Longitud de desarrollo";
		"Otro, ℓ_d" 		"Lecho Inferior, ℓ_d" 		"Gancho, ℓ_dh";
	]
	development_length_tension_units = [
		preferred_length preferred_length preferred_length;
	]
	development_length_tension = hcat(	
		ℓ_d_table_top  ./ preferred_length, 
		ℓ_d_table_bot  ./ preferred_length,
		ℓ_d_table_hook ./ preferred_length,

	)

	# Splice in TENSION
	splice_tension_header = [
		"Tensión" 	"Tensión" 	"Tensión" 	"Tensión";
		"Traslape, ℓ_st" 	"Traslape, ℓ_st" 	"Traslape, ℓ_st" 	"Traslape, ℓ_st";
		"Clase A" 	"Clase A" 	"Clase B" 	"Clase B";
		"Otro" 		"Lecho Inferior" 		"Otro" 		"Lecho Inferior";
	]
	splice_tension_units = [
		preferred_length preferred_length preferred_length preferred_length;
	]
	splice_tension = hcat(
		ℓ_st_table_top_classA  ./ preferred_length, 
		ℓ_st_table_bot_classA  ./ preferred_length,
		ℓ_st_table_top_classB  ./ preferred_length, 
		ℓ_st_table_bot_classB  ./ preferred_length,
	)

	# Development length in COMPRESSION
	development_length_compression_header = [
		"Compresión";
		"Development, ℓ_dc";
		"Development, ℓ_dc";
		"Development, ℓ_dc";
	]
	development_length_compression_units = [
		preferred_length
	]
	development_length_compression = hcat(
		ℓ_dc_table ./ preferred_length,
	)

	# Splice in COMPRESSION
	if f_y_used ≤ 80_000.0u"psi"
		splice_compression_header = [
			"Compresión";
			"Traslape, ℓ_sc";
			"Traslape, ℓ_sc";
			"Traslape, ℓ_sc";
		]
		splice_compression_units = [
			preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table  ./ preferred_length, 
		)
		
	else
		splice_compression_header = [
			"Compresión" 	"Compresión" 	"Compresión" 	"Compresión";
			"Traslape, ℓ_sc" 		"Traslape, ℓ_sc" 		"Traslape, ℓ_sc" 		"Traslape, ℓ_sc";
			"Clase A" 		"Clase A" 		"Clase B" 		"Clase B";
			"Otro" 			"Lecho Inferior" 			"Otro" 			"Lecho Inferior";
		]
		splice_compression_units = [
			preferred_length preferred_length preferred_length preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table_top_classA  ./ preferred_length, 
			ℓ_sc_table_bot_classA  ./ preferred_length,
			ℓ_sc_table_top_classB  ./ preferred_length, 
			ℓ_sc_table_bot_classB  ./ preferred_length,
		)
	end # if



	# Converting to CELLS
	bar_size_cells = [
		Cell.(bar_size_header, bold = true, merge = true, valign = :center);
		Cell.(bar_size_units, italic = true, merge = false, valign = :center);
		Cell.(bar_size, bold = true, merge = false, valign = :center);
	]
	development_length_tension_cells = [
		Cell.(development_length_tension_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_tension_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_tension, bold = true, merge = false, valign = :center);
	]

	splice_tension_cells = [
		Cell.(splice_tension_header, bold = true, merge = true, valign = :center);
		Cell.(splice_tension_units, italic = true, merge = false, valign = :center);
		Cell.(splice_tension, bold = true, merge = false, valign = :center);
	]

	development_length_compression_cells = [
		Cell.(development_length_compression_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_compression_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_compression, bold = true, merge = false, valign = :center);
	]

	splice_compression_cells = [
		Cell.(splice_compression_header, bold = true, merge = true, valign = :center);
		Cell.(splice_compression_units, italic = true, merge = false, valign = :center);
		Cell.(splice_compression, bold = true, merge = false, valign = :center);
	]

	Table(
		header = 5,
		footer = 18,
		footnotes = notes_es,
		# linebreak_footnotes = false,
		rowgaps = [8 => 5.0, 11 => 5.0, 14 => 5.0],
		colgaps = [2 => 10.0, #=3 => 10.0, 4 => 0.0=#],
		hcat(
		    bar_size_cells,
			development_length_tension_cells,
			splice_tension_cells,
			development_length_compression_cells,
			splice_compression_cells,
			# notes
		),
	    round_digits = 3,
    	round_mode = :sigdigits, # :auto :digits :sigdigits
		trailing_zeros = false,
	)
end

# ╔═╡ 9aa4b5c4-81c5-43b6-b3ec-32faf9c30695
let
	# Print in a table all development lengths

	# Bar size
	bar_size_header = [
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
		"Bar Size" "Bar Size";
	]
	bar_size_units = [
		"1/8in" "mm";
	]
	bar_size = hcat(
		"#" .* string.(rebar_list), 
		"#" .* string.(rebar_list_SI), 
	)

	# Development length in TENSION
	development_length_tension_header = [
		"Development" 		"Development" 		"Development";
		"Development" 	"Development" 	"Development";
		"Development" 	"Development" 	"Development";
		"Other, ℓ_d" 		"Bot, ℓ_d" 		"Hook, ℓ_dh";
	]
	development_length_tension_units = [
		preferred_length preferred_length preferred_length;
	]
	development_length_tension = hcat(	
		ℓ_d_table_top  ./ preferred_length, 
		ℓ_d_table_bot  ./ preferred_length,
		ℓ_d_table_hook ./ preferred_length,

	)

	# Splice in TENSION
	splice_tension_header = [
		"Splice" 	"Splice" 	"Splice" 	"Splice";
		"ℓ_st" 	"ℓ_st" 	"ℓ_st" 	"ℓ_st";
		"Class A" 	"Class A" 	"Class B" 	"Class B";
		"Other" 		"Bot" 		"Other" 		"Bot";
	]
	splice_tension_units = [
		preferred_length preferred_length preferred_length preferred_length;
	]
	splice_tension = hcat(
		ℓ_st_table_top_classA  ./ preferred_length, 
		ℓ_st_table_bot_classA  ./ preferred_length,
		ℓ_st_table_top_classB  ./ preferred_length, 
		ℓ_st_table_bot_classB  ./ preferred_length,
	)

	# Development length in COMPRESSION
	development_length_compression_header = [
		"Development";
		"ℓ_dc";
		"ℓ_dc";
		"ℓ_dc";
	]
	development_length_compression_units = [
		preferred_length
	]
	development_length_compression = hcat(
		ℓ_dc_table ./ preferred_length,
	)

	# Splice in COMPRESSION
	if f_y_used ≤ 80_000.0u"psi"
		splice_compression_header = [
			"Splice";
			"ℓ_sc";
			"ℓ_sc";
			"ℓ_sc";
		]
		splice_compression_units = [
			preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table  ./ preferred_length, 
		)
		
	else
		splice_compression_header = [
			"Splice" 	"Splice" 	"Splice" 	"Splice";
			"ℓ_sc" 		"ℓ_sc" 		"ℓ_sc" 		"ℓ_sc";
			"Class A" 		"Class A" 		"Class B" 		"Class B";
			"Other" 			"Bot" 			"Other" 			"Bot";
		]
		splice_compression_units = [
			preferred_length preferred_length preferred_length preferred_length;
		]
		splice_compression = hcat(
			ℓ_sc_table_top_classA  ./ preferred_length, 
			ℓ_sc_table_bot_classA  ./ preferred_length,
			ℓ_sc_table_top_classB  ./ preferred_length, 
			ℓ_sc_table_bot_classB  ./ preferred_length,
		)
	end # if



	# Converting to CELLS
	bar_size_cells = [
		Cell.(bar_size_header, bold = true, merge = true, valign = :center);
		Cell.(bar_size_units, italic = true, merge = false, valign = :center);
		Cell.(bar_size, bold = true, merge = false, valign = :center);
	]
	development_length_tension_cells = [
		Cell.(development_length_tension_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_tension_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_tension, bold = true, merge = false, valign = :center);
	]

	splice_tension_cells = [
		Cell.(splice_tension_header, bold = true, merge = true, valign = :center);
		Cell.(splice_tension_units, italic = true, merge = false, valign = :center);
		Cell.(splice_tension, bold = true, merge = false, valign = :center);
	]

	development_length_compression_cells = [
		Cell.(development_length_compression_header, bold = true, merge = true, valign = :center);
		Cell.(development_length_compression_units, italic = true, merge = false, valign = :center);
		Cell.(development_length_compression, bold = true, merge = false, valign = :center);
	]

	splice_compression_cells = [
		Cell.(splice_compression_header, bold = true, merge = true, valign = :center);
		Cell.(splice_compression_units, italic = true, merge = false, valign = :center);
		Cell.(splice_compression, bold = true, merge = false, valign = :center);
	]

	Table(
		header = 5,
		footer = 18,
		footnotes = notes,
		# linebreak_footnotes = false,
		rowgaps = [8 => 5.0, 11 => 5.0, 14 => 5.0],
		colgaps = [2 => 10.0, #=3 => 10.0, 4 => 0.0=#],
		hcat(
		    bar_size_cells,
			development_length_tension_cells,
			splice_tension_cells,
			development_length_compression_cells,
			splice_compression_cells,
			# notes
		),
	    round_digits = 3,
    	round_mode = :sigdigits, # :auto :digits :sigdigits
		trailing_zeros = false,
	)
end

# ╔═╡ 29ac282c-0429-47a0-9da2-b7a0449b4e4a
# Left align Latexify functions
left_align_in_pluto()

# ╔═╡ f1d07d6d-a126-4f41-a246-758e0861aed3
# in JS console paste this to allow style inside """ """
# window.PLUTO_TOGGLE_CM_MIXED_PARSER()

# ╔═╡ a9a8cd53-ed30-4d21-af3c-dfb6e2f46440
# let
# @handcalcs begin

# end precision=2 len=:long
# end

# ╔═╡ 031d5747-990b-4ca6-b817-2154b27dce5b
md"""
##### SummaryTables.jl: Example
"""

# ╔═╡ b8f2e603-d164-4d40-9ba5-621c8f2c9308
let
	categories = ["Deciduous", "Deciduous", "Evergreen", "Evergreen", "Evergreen"]
	species = ["Beech", "Oak", "Fir", "Spruce", "Pine"]
	fake_data = [
	    "35m" "40m" "38m" "27m" "29m"
	    "10k" "12k" "18k" "9k" "7k"
	    "500yr" "800yr" "600yr" "700yr" "400yr"
	    "80\$" "150\$" "40\$" "70\$" "50\$"
	]
	labels = ["", "", "Size", Annotated("Water consumption", "Liters per year"), "Age", "Value"]
	
	body = [
	    Cell.(categories, bold = true, merge = true, border_bottom = true)';
	    Cell.(species)';
	    Cell.(fake_data)
	]
	
	Table(hcat(
	    Cell.(labels, italic = true, halign = :right),
	    body
	))
end

# ╔═╡ 5fef5947-3676-44a7-9cbb-53146c7e14e8
md"""
##### Bond tables
"""

# ╔═╡ fc849125-4303-4b13-a0a6-61e1c5bcae84
# single_bonds = @BondsList "Plot Variables" begin
# 	"Pointing Angle [°]" = @bind θ₀ Slider(-90:90; default=0,show_value=true)
# end

# ╔═╡ fdb85668-cc2e-4489-a01e-ed778ca1fb6a
# bond = @bind params @NTBond "Antenna Parameters" begin
# 	N = ("Number of Elements", Slider(10:30; show_value=true))
# 	spacing = ("Elements Spacing [ͅλ]", Slider(range(0.5, 2.5; step=0.05); show_value=true))
# end

# ╔═╡ 26c6c526-64fa-4aa4-a79f-a2bcf47c8d88
# BondTable([bond, single_bonds])

# ╔═╡ 3c5fd804-404d-46d6-82b3-e867bbb34aa3
md"""
##### Input data NOT as BondTable
"""

# ╔═╡ d350a9a1-44c7-4001-966e-9317cfced115
# let
# reset_selected_to_defaults; 
	
# # text = Dict(
# # 	"en" => md"Language:",
# # 	"es" => md"Lenguaje:",
# # );
	
# md"""
#  Language:
#  $(
# 	@bind language Select(
# 		[
# 			"en" => "English";
# 			"es" => "Español";
# 		], 
# 		default="es"
# 	)
# )
# """
# end

# ╔═╡ 156eb9b3-b31c-4795-90d5-c00795489e87
# let
# 	text = Dict(
# 		"en" => md"Unit System:",
# 		"es" => md"Sistema de Unidades:",
# 	)
	
# md"""
#  $(text[language])
#  $(
# 	@bind unit_system Select(
# 			[
# 				"mks";
# 				"SI";
# 				"English";
# 			], 
# 			default="mks"
# 		)
# 	)
# """
# end

# ╔═╡ c433d46d-71a6-4e4e-b3e8-8bf3ed17630d
# let
# reset_selected_to_defaults; 
	
# text = Dict(
# 	"en" => md"Concrete compressive strength:",
# 	"es" => md"Resistencia a compresión del concreto:",
# );
	
# md"""
#  $(text[language]) 
#  $(
# 	@bind f_c_selected NumberField(
# 		f_c_min:f_c_increments:f_c_max, 
# 		default=f_c_default
# 	)
#  ) $((preferred_stress))
# """ # $(latexify(preferred_stress))
# end

# ╔═╡ 3e90eab6-78fb-4b81-b9e7-0dbe633edb57
# let
# reset_selected_to_defaults; 
	
# text = Dict(
# 	"en" => md"Lightweight concrete:",
# 	"es" => md"Concreto ligero:",
# );
	
# md"""
#  $(text[language]) 
#  $(
# 	@bind lightweight_concrete_selected Select(
# 		[
# 			false => "No", 
# 			true => "Yes"
# 		], 
# 		default=false
# 	)
# )
# """
# end

# ╔═╡ b93b00c9-4369-4e43-b38b-2c22aa96e352
# let
# reset_selected_to_defaults; 
	
# text = Dict(
# 	"en" => md"Reinforcement grade:",
# 	"es" => md"Grado del refuerzo:",
# );
	
# md"""
#  $(text[language]) 
#  $(
# 	@bind reinforcement_grade_selected Select(
# 		[
# 			40 => "Grade 40", 
# 			60 => "Grade 60", 
# 			75 => "Grade 75", 
# 			80 => "Grade 80", 
# 			100 => "Grade 100", 
# 			0 => "Custom", 
# 		], 
# 		default=60
# 	)
# ) ksi
# """
# end

# ╔═╡ 9cc812a2-0765-48ff-91df-e1aebace845e
# reinforcement_grade_selected == 0 ? md"""
# Custom reinforcement grade: 
# $(
# 	@bind f_y_selected NumberField(
# 		f_y_min:f_y_increments:f_y_max, 
# 		default=f_y_default
# 	)
# ) 
# $(preferred_stress)

# """ : md""

# ╔═╡ 5b68de08-9fbb-4b43-8d86-5cc865de814d
md"""
##### Create BondTable
"""

# ╔═╡ 39ae2e59-0496-4e90-b12f-bb7ad90dc229
BondTable([
	bond_language, 
	bond_settings,
	bond_data,
	bond_custom,
], description="Data")

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Handcalcs = "e8a07092-c156-4455-ab8e-ed8bc81edefb"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
LaTeXStrings = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
Latexify = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
PlutoDevMacros = "a0499f29-c39b-4c5c-807c-88074221b949"
PlutoExtras = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
PlutoPlotly = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
PrettyTables = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
SummaryTables = "6ce4ecf0-73a7-4ce3-9fb4-80ebfe887b60"
Symbolics = "0c5d862f-8b57-4792-8d23-62f2024744c7"
Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"
UnitfulLatexify = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"

[compat]
Handcalcs = "~0.4.4"
HypertextLiteral = "~0.9.5"
LaTeXStrings = "~1.4.0"
Latexify = "~0.16.6"
PlutoDevMacros = "~0.9.0"
PlutoExtras = "~0.7.14"
PlutoPlotly = "~0.6.2"
PlutoUI = "~0.7.61"
PrettyTables = "~2.4.0"
SummaryTables = "~3.3.0"
Symbolics = "~6.29.2"
Unitful = "~1.22.0"
UnitfulLatexify = "~1.6.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.4"
manifest_format = "2.0"
project_hash = "072e473c813688cabbf16db620d1e25600418bc7"

[[deps.ADTypes]]
git-tree-sha1 = "e2478490447631aedba0823d4d7a80b2cc8cdb32"
uuid = "47edcb42-4c32-4615-8424-f2b9edc5f35b"
version = "1.14.0"

    [deps.ADTypes.extensions]
    ADTypesChainRulesCoreExt = "ChainRulesCore"
    ADTypesConstructionBaseExt = "ConstructionBase"
    ADTypesEnzymeCoreExt = "EnzymeCore"

    [deps.ADTypes.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ConstructionBase = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
    EnzymeCore = "f151be2c-9106-41f4-ab19-57ee4f262869"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Accessors]]
deps = ["CompositionsBase", "ConstructionBase", "Dates", "InverseFunctions", "MacroTools"]
git-tree-sha1 = "3b86719127f50670efe356bc11073d84b4ed7a5d"
uuid = "7d9f7c33-5ae7-4f3b-8dc6-eff91059b697"
version = "0.1.42"

    [deps.Accessors.extensions]
    AxisKeysExt = "AxisKeys"
    IntervalSetsExt = "IntervalSets"
    LinearAlgebraExt = "LinearAlgebra"
    StaticArraysExt = "StaticArrays"
    StructArraysExt = "StructArrays"
    TestExt = "Test"
    UnitfulExt = "Unitful"

    [deps.Accessors.weakdeps]
    AxisKeys = "94b1ba4f-4ee9-5380-92f1-94cde586c3c5"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "f7817e2e585aa6d924fd714df1e2a84be7896c60"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.3.0"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.ArrayInterface]]
deps = ["Adapt", "LinearAlgebra"]
git-tree-sha1 = "017fcb757f8e921fb44ee063a7aafe5f89b86dd1"
uuid = "4fba245c-0d91-5ea0-9b3e-6abc04ee57a9"
version = "7.18.0"

    [deps.ArrayInterface.extensions]
    ArrayInterfaceBandedMatricesExt = "BandedMatrices"
    ArrayInterfaceBlockBandedMatricesExt = "BlockBandedMatrices"
    ArrayInterfaceCUDAExt = "CUDA"
    ArrayInterfaceCUDSSExt = "CUDSS"
    ArrayInterfaceChainRulesCoreExt = "ChainRulesCore"
    ArrayInterfaceChainRulesExt = "ChainRules"
    ArrayInterfaceGPUArraysCoreExt = "GPUArraysCore"
    ArrayInterfaceReverseDiffExt = "ReverseDiff"
    ArrayInterfaceSparseArraysExt = "SparseArrays"
    ArrayInterfaceStaticArraysCoreExt = "StaticArraysCore"
    ArrayInterfaceTrackerExt = "Tracker"

    [deps.ArrayInterface.weakdeps]
    BandedMatrices = "aae01518-5342-5314-be14-df237901396f"
    BlockBandedMatrices = "ffab5731-97b5-5995-9138-79e8c1846df0"
    CUDA = "052768ef-5323-5732-b1bb-66c8b64840ba"
    CUDSS = "45b445bb-4962-46a0-9369-b4df9d0f772e"
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArraysCore = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.Bijections]]
git-tree-sha1 = "d8b0439d2be438a5f2cd68ec158fe08a7b2595b7"
uuid = "e2ed5e7c-b2de-5872-ae92-c73ca462fb04"
version = "0.1.9"

[[deps.CategoricalArrays]]
deps = ["DataAPI", "Future", "Missings", "Printf", "Requires", "Statistics", "Unicode"]
git-tree-sha1 = "1568b28f91293458345dabba6a5ea3f183250a61"
uuid = "324d7699-5711-5eae-9e2f-1d82baa6b597"
version = "0.10.8"

    [deps.CategoricalArrays.extensions]
    CategoricalArraysJSONExt = "JSON"
    CategoricalArraysRecipesBaseExt = "RecipesBase"
    CategoricalArraysSentinelArraysExt = "SentinelArrays"
    CategoricalArraysStructTypesExt = "StructTypes"

    [deps.CategoricalArrays.weakdeps]
    JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SentinelArrays = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
    StructTypes = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1713c74e00545bfe14605d2a2be1712de8fbcb58"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "7eee164f122511d3e4e1ebadb7956939ea7e1c77"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "403f2d8e209681fcbd9468a8514efff3ea08452e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.29.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Combinatorics]]
git-tree-sha1 = "08c8b6831dc00bfea825826be0bc8336fc369860"
uuid = "861a8166-3701-5b0c-9a16-15d98fcdc6aa"
version = "1.0.2"

[[deps.CommonSolve]]
git-tree-sha1 = "0eee5eb66b1cf62cd6ad1b460238e60e4b09400c"
uuid = "38540f10-b2f7-11e9-35d8-d573e4eb0ff2"
version = "0.2.4"

[[deps.CommonWorldInvalidations]]
git-tree-sha1 = "ae52d1c52048455e85a387fbee9be553ec2b68d0"
uuid = "f70d9fcc-98c5-4d4a-abd7-e4cdeebd8ca8"
version = "1.0.0"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.CompositeTypes]]
git-tree-sha1 = "bce26c3dab336582805503bed209faab1c279768"
uuid = "b152e2b5-7a66-4b01-a709-34e65c35f657"
version = "0.1.4"

[[deps.CompositionsBase]]
git-tree-sha1 = "802bb88cd69dfd1509f6670416bd4434015693ad"
uuid = "a33af91c-f02d-484b-be07-31d278c5ca2b"
version = "0.1.2"
weakdeps = ["InverseFunctions"]

    [deps.CompositionsBase.extensions]
    CompositionsBaseInverseFunctionsExt = "InverseFunctions"

[[deps.ConstructionBase]]
git-tree-sha1 = "76219f1ed5771adbb096743bff43fb5fdd4c1157"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.5.8"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelimitedFiles]]
deps = ["Mmap"]
git-tree-sha1 = "9e2f36d3c96a820c678f2f1f1782582fcf685bae"
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"
version = "1.9.1"

[[deps.DiffRules]]
deps = ["IrrationalConstants", "LogExpFunctions", "NaNMath", "Random", "SpecialFunctions"]
git-tree-sha1 = "23163d55f885173722d1e4cf0f6110cdbaf7e272"
uuid = "b552c78f-8df3-52c6-915a-8e097449b14b"
version = "1.15.1"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "0b4190661e8a4e51a842070e7dd4fae440ddb7f4"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.118"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "2fb1e02f2b635d0845df5d7c167fec4dd739b00d"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.3"

[[deps.DomainSets]]
deps = ["CompositeTypes", "IntervalSets", "LinearAlgebra", "Random", "StaticArrays"]
git-tree-sha1 = "a7e9f13f33652c533d49868a534bfb2050d1365f"
uuid = "5b8099bc-c8ec-5219-889f-1d9e522a28bf"
version = "0.7.15"

    [deps.DomainSets.extensions]
    DomainSetsMakieExt = "Makie"

    [deps.DomainSets.weakdeps]
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.DynamicPolynomials]]
deps = ["Future", "LinearAlgebra", "MultivariatePolynomials", "MutableArithmetics", "Reexport", "Test"]
git-tree-sha1 = "9a3ae38b460449cc9e7dd0cfb059c76028724627"
uuid = "7c1d4256-1411-5781-91ec-d7bc3513ac07"
version = "0.6.1"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.ExprTools]]
git-tree-sha1 = "27415f162e6028e81c72b82ef756bf321213b6ec"
uuid = "e2ba6199-217a-4e67-a87a-7c52f15ade04"
version = "0.1.10"

[[deps.ExproniconLite]]
git-tree-sha1 = "c13f0b150373771b0fdc1713c97860f8df12e6c2"
uuid = "55351af7-c7e9-48d6-89ff-24e801d99491"
version = "0.10.14"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "f6f44ab51d253f851d2084c1ac761bb679798408"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.2.1"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FunctionWrappers]]
git-tree-sha1 = "d62485945ce5ae9c0c48f124a84998d755bae00e"
uuid = "069b7b12-0de2-55c6-9aab-29f3d0a68a2e"
version = "1.1.3"

[[deps.FunctionWrappersWrappers]]
deps = ["FunctionWrappers"]
git-tree-sha1 = "b104d487b34566608f8b4e1c39fb0b10aa279ff8"
uuid = "77dc65aa-8811-40c2-897b-53d922fa7daf"
version = "0.1.3"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GPUArraysCore]]
deps = ["Adapt"]
git-tree-sha1 = "83cf05ab16a73219e5f6bd1bdfa9848fa24ac627"
uuid = "46192b85-c4d5-4398-a991-12ede77f4527"
version = "0.2.0"

[[deps.Handcalcs]]
deps = ["AbstractTrees", "CodeTracking", "InteractiveUtils", "LaTeXStrings", "Latexify", "MacroTools", "PrecompileTools", "Revise", "TestHandcalcFunctions"]
git-tree-sha1 = "7f27904769778c2e476a6da73a9021e6589c9d21"
uuid = "e8a07092-c156-4455-ab8e-ed8bc81edefb"
version = "0.4.4"

[[deps.HashArrayMappedTries]]
git-tree-sha1 = "2eaa69a7cab70a52b9687c8bf950a5a93ec895ae"
uuid = "076d061b-32b6-4027-95e0-9a2c6f6d7e74"
version = "0.2.0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "68c173f4f449de5b438ee67ed0c9c748dc31a2ec"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.28"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.HypothesisTests]]
deps = ["Combinatorics", "Distributions", "LinearAlgebra", "Printf", "Random", "Rmath", "Roots", "Statistics", "StatsAPI", "StatsBase"]
git-tree-sha1 = "6c3ce99fdbaf680aa6716f4b919c19e902d67c9c"
uuid = "09f84164-cd44-5f33-b23f-e6b0d136a0d5"
version = "0.11.3"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.InlineStrings]]
git-tree-sha1 = "6a9fde685a7ac1eb3495f8e812c5a7c3711c2d5e"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.3"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntegerMathUtils]]
git-tree-sha1 = "b8ffb903da9f7b8cf695a8bead8e01814aa24b30"
uuid = "18e54dd8-cb9d-406c-a71d-865a43cbb235"
version = "0.1.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.IntervalSets]]
git-tree-sha1 = "dba9ddf07f77f60450fe5d2e2beb9854d9a49bd0"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.10"
weakdeps = ["Random", "RecipesBase", "Statistics"]

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

[[deps.InverseFunctions]]
git-tree-sha1 = "a779299d77cd080bf77b97535acecd73e1c5e5cb"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.17"
weakdeps = ["Dates", "Test"]

    [deps.InverseFunctions.extensions]
    InverseFunctionsDatesExt = "Dates"
    InverseFunctionsTestExt = "Test"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.Jieko]]
deps = ["ExproniconLite"]
git-tree-sha1 = "2f05ed29618da60c06a87e9c033982d4f71d0b6c"
uuid = "ae98c720-c025-4a4a-838c-29b094483192"
version = "0.2.1"

[[deps.JuliaInterpreter]]
deps = ["CodeTracking", "InteractiveUtils", "Random", "UUIDs"]
git-tree-sha1 = "a434e811d10e7cbf4f0674285542e697dca605d0"
uuid = "aa1ae85d-cabe-5617-a682-6adf51b2e16a"
version = "0.9.42"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.Latexify]]
deps = ["Format", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "OrderedCollections", "Requires"]
git-tree-sha1 = "cd714447457c660382fe634710fb56eb255ee42e"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.6"

    [deps.Latexify.extensions]
    DataFramesExt = "DataFrames"
    SparseArraysExt = "SparseArrays"
    SymEngineExt = "SymEngine"

    [deps.Latexify.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    SymEngine = "123dc426-2d89-5057-bbad-38513e3affd8"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.LoweredCodeUtils]]
deps = ["JuliaInterpreter"]
git-tree-sha1 = "688d6d9e098109051ae33d126fcfc88c4ce4a021"
uuid = "6f1432cf-f94c-5a45-995e-cdbf5db27b0b"
version = "3.1.0"

[[deps.MIMEs]]
git-tree-sha1 = "1833212fd6f580c20d4291da9c1b4e8a655b128e"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.0.0"

[[deps.MacroTools]]
git-tree-sha1 = "72aebe0b5051e5143a079a4685a46da330a40472"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.15"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.Moshi]]
deps = ["ExproniconLite", "Jieko"]
git-tree-sha1 = "453de0fc2be3d11b9b93ca4d0fddd91196dcf1ed"
uuid = "2e0e35c7-a2e4-4343-998d-7ef72827ed2d"
version = "0.3.5"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.MultipleTesting]]
deps = ["Distributions", "SpecialFunctions", "StatsBase"]
git-tree-sha1 = "1e98f8f732e7035c4333135b75605b74f3462b9b"
uuid = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
version = "0.6.0"

[[deps.MultivariatePolynomials]]
deps = ["ChainRulesCore", "DataStructures", "LinearAlgebra", "MutableArithmetics"]
git-tree-sha1 = "8d39779e29f80aa6c071e7ac17101c6e31f075d7"
uuid = "102ac46a-7ee4-5c85-9060-abc95bfdeaa3"
version = "0.5.7"

[[deps.MutableArithmetics]]
deps = ["LinearAlgebra", "SparseArrays", "Test"]
git-tree-sha1 = "491bdcdc943fcbc4c005900d7463c9f216aabf4c"
uuid = "d8a4904e-b15c-11e9-3269-09a3773c0cb0"
version = "1.6.4"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "cc0a5deefdb12ab3a096f00a6d42133af4560d71"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.2"

[[deps.NaturalSort]]
git-tree-sha1 = "eda490d06b9f7c00752ee81cfa451efe55521e21"
uuid = "c020b1a1-e9b0-503a-9c33-f039bfc54a85"
version = "1.0.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OffsetArrays]]
git-tree-sha1 = "5e1897147d1ff8d98883cda2be2187dcf57d8f0c"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.15.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+4"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "cc4054e898b852042d7b503313f7ad03de99c3dd"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.0"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "966b85253e959ea89c53a9abebbf2e964fbf593b"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.32"

[[deps.Parameters]]
deps = ["OrderedCollections", "UnPack"]
git-tree-sha1 = "34c0e9ad262e5f7fc75b10a9952ca7692cfc5fbe"
uuid = "d96e819e-fc66-5662-9728-84c9c7592b0a"
version = "0.12.3"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "8489905bcdbcfac64d1daa51ca07c0d8f0283821"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PlotlyBase]]
deps = ["ColorSchemes", "Colors", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "90af5c9238c1b3b25421f1fdfffd1e8fca7a7133"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.20"

    [deps.PlotlyBase.extensions]
    DataFramesExt = "DataFrames"
    DistributionsExt = "Distributions"
    IJuliaExt = "IJulia"
    JSON3Ext = "JSON3"

    [deps.PlotlyBase.weakdeps]
    DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
    Distributions = "31c24e10-a181-5473-b8eb-7969acd0382f"
    IJulia = "7073ff75-c697-5162-941a-fcdaad2a7d2a"
    JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"

[[deps.PlutoDevMacros]]
deps = ["JuliaInterpreter", "Logging", "MacroTools", "Pkg", "TOML"]
git-tree-sha1 = "72f65885168722413c7b9a9debc504c7e7df7709"
uuid = "a0499f29-c39b-4c5c-807c-88074221b949"
version = "0.9.0"

[[deps.PlutoExtras]]
deps = ["AbstractPlutoDingetjes", "DocStringExtensions", "HypertextLiteral", "InteractiveUtils", "Markdown", "PlutoUI", "REPL", "Random"]
git-tree-sha1 = "8933d5e99795923433eb161223dc666d70b18a09"
uuid = "ed5d0301-4775-4676-b788-cf71e66ff8ed"
version = "0.7.14"

[[deps.PlutoPlotly]]
deps = ["AbstractPlutoDingetjes", "Artifacts", "ColorSchemes", "Colors", "Dates", "Downloads", "HypertextLiteral", "InteractiveUtils", "LaTeXStrings", "Markdown", "Pkg", "PlotlyBase", "PrecompileTools", "Reexport", "ScopedValues", "Scratch", "TOML"]
git-tree-sha1 = "9ebe25fc4703d4112cc418834d5e4c9a4b29087d"
uuid = "8e989ff0-3d88-8e9f-f020-2b208a939ff0"
version = "0.6.2"

    [deps.PlutoPlotly.extensions]
    PlotlyKaleidoExt = "PlotlyKaleido"
    UnitfulExt = "Unitful"

    [deps.PlutoPlotly.weakdeps]
    PlotlyKaleido = "f2990250-8cf9-495f-b13a-cce12b45703c"
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "7e71a55b87222942f0f9337be62e26b1f103d3e4"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.61"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Primes]]
deps = ["IntegerMathUtils"]
git-tree-sha1 = "cb420f77dc474d23ee47ca8d14c90810cafe69e7"
uuid = "27ebfcd6-29c5-5fa9-bf4b-fb8fc14df3ae"
version = "0.5.6"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RecipesBase]]
deps = ["PrecompileTools"]
git-tree-sha1 = "5c3d09cc4f31f5fc6af001c250bf1278733100ff"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.3.4"

[[deps.RecursiveArrayTools]]
deps = ["Adapt", "ArrayInterface", "DocStringExtensions", "GPUArraysCore", "IteratorInterfaceExtensions", "LinearAlgebra", "RecipesBase", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface", "Tables"]
git-tree-sha1 = "35ac79a85c8086892258581d8b6df9cd8db5c91a"
uuid = "731186ca-8d62-57ce-b412-fbd966d074cd"
version = "3.31.1"

    [deps.RecursiveArrayTools.extensions]
    RecursiveArrayToolsFastBroadcastExt = "FastBroadcast"
    RecursiveArrayToolsForwardDiffExt = "ForwardDiff"
    RecursiveArrayToolsMeasurementsExt = "Measurements"
    RecursiveArrayToolsMonteCarloMeasurementsExt = "MonteCarloMeasurements"
    RecursiveArrayToolsReverseDiffExt = ["ReverseDiff", "Zygote"]
    RecursiveArrayToolsSparseArraysExt = ["SparseArrays"]
    RecursiveArrayToolsStructArraysExt = "StructArrays"
    RecursiveArrayToolsTrackerExt = "Tracker"
    RecursiveArrayToolsZygoteExt = "Zygote"

    [deps.RecursiveArrayTools.weakdeps]
    FastBroadcast = "7034ab61-46d4-4ed7-9d0f-46aef9175898"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Measurements = "eff96d63-e80a-5855-80a2-b1b0885c5ab7"
    MonteCarloMeasurements = "0987c9cc-fe09-11e8-30f0-b96dd679fdca"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StructArrays = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
    Tracker = "9f7883ad-71c0-57eb-9f7f-b5c9e6d3789c"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Revise]]
deps = ["CodeTracking", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "9bb80533cb9769933954ea4ffbecb3025a783198"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.7.2"
weakdeps = ["Distributed"]

    [deps.Revise.extensions]
    DistributedExt = "Distributed"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.Roots]]
deps = ["Accessors", "CommonSolve", "Printf"]
git-tree-sha1 = "442b4353ee8c26756672afb2db81894fc28811f3"
uuid = "f2b01f46-fcfa-551c-844a-d8ac1e96c665"
version = "2.2.6"

    [deps.Roots.extensions]
    RootsChainRulesCoreExt = "ChainRulesCore"
    RootsForwardDiffExt = "ForwardDiff"
    RootsIntervalRootFindingExt = "IntervalRootFinding"
    RootsSymPyExt = "SymPy"
    RootsSymPyPythonCallExt = "SymPyPythonCall"

    [deps.Roots.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalRootFinding = "d2bf35a9-74e0-55ec-b149-d360ff49b807"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"
    SymPyPythonCall = "bc8888f7-b21e-4b7c-a06a-5d9c9496438c"

[[deps.RuntimeGeneratedFunctions]]
deps = ["ExprTools", "SHA", "Serialization"]
git-tree-sha1 = "04c968137612c4a5629fa531334bb81ad5680f00"
uuid = "7e49a35a-f44a-4d26-94aa-eba1b4ca6b47"
version = "0.5.13"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SciMLBase]]
deps = ["ADTypes", "Accessors", "ArrayInterface", "CommonSolve", "ConstructionBase", "Distributed", "DocStringExtensions", "EnumX", "FunctionWrappersWrappers", "IteratorInterfaceExtensions", "LinearAlgebra", "Logging", "Markdown", "Moshi", "PrecompileTools", "Preferences", "Printf", "RecipesBase", "RecursiveArrayTools", "Reexport", "RuntimeGeneratedFunctions", "SciMLOperators", "SciMLStructures", "StaticArraysCore", "Statistics", "SymbolicIndexingInterface"]
git-tree-sha1 = "c779c485f384cc824dac44ab1ef1440209027016"
uuid = "0bca4576-84f4-4d90-8ffe-ffa030f20462"
version = "2.76.0"

    [deps.SciMLBase.extensions]
    SciMLBaseChainRulesCoreExt = "ChainRulesCore"
    SciMLBaseMLStyleExt = "MLStyle"
    SciMLBaseMakieExt = "Makie"
    SciMLBasePartialFunctionsExt = "PartialFunctions"
    SciMLBasePyCallExt = "PyCall"
    SciMLBasePythonCallExt = "PythonCall"
    SciMLBaseRCallExt = "RCall"
    SciMLBaseZygoteExt = ["Zygote", "ChainRulesCore"]

    [deps.SciMLBase.weakdeps]
    ChainRules = "082447d4-558c-5d27-93f4-14fc19e9eca2"
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    MLStyle = "d8e11817-5142-5d16-987a-aa16d5891078"
    Makie = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
    PartialFunctions = "570af359-4316-4cb7-8c74-252c00c2016b"
    PyCall = "438e738f-606a-5dbb-bf0a-cddfbfd45ab0"
    PythonCall = "6099a3de-0909-46bc-b1f4-468b9a2dfc0d"
    RCall = "6f49c342-dc21-5d91-9882-a32aef131414"
    Zygote = "e88e6eb3-aa80-5325-afca-941959d7151f"

[[deps.SciMLOperators]]
deps = ["Accessors", "ArrayInterface", "DocStringExtensions", "LinearAlgebra", "MacroTools"]
git-tree-sha1 = "6149620767866d4b0f0f7028639b6e661b6a1e44"
uuid = "c0aeaf25-5076-4817-a8d5-81caf7dfa961"
version = "0.3.12"
weakdeps = ["SparseArrays", "StaticArraysCore"]

    [deps.SciMLOperators.extensions]
    SciMLOperatorsSparseArraysExt = "SparseArrays"
    SciMLOperatorsStaticArraysCoreExt = "StaticArraysCore"

[[deps.SciMLStructures]]
deps = ["ArrayInterface"]
git-tree-sha1 = "566c4ed301ccb2a44cbd5a27da5f885e0ed1d5df"
uuid = "53ae85a6-f571-4167-b2af-e1d143709226"
version = "1.7.0"

[[deps.ScopedValues]]
deps = ["HashArrayMappedTries", "Logging"]
git-tree-sha1 = "1147f140b4c8ddab224c94efa9569fc23d63ab44"
uuid = "7e506255-f358-4e82-b7e4-beb19740aa63"
version = "1.3.0"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Setfield]]
deps = ["ConstructionBase", "Future", "MacroTools", "StaticArraysCore"]
git-tree-sha1 = "c5391c6ace3bc430ca630251d02ea9687169ca68"
uuid = "efcf1570-3423-57d1-acb7-fd33fddbac46"
version = "1.1.2"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "64cca0c26b4f31ba18f13f6c12af7c85f478cfde"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.0"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1ff449ad350c9c4cbc756624d6f8a8c3ef56d3ed"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.0"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "29321314c920c26684834965ec2ce0dacc9cf8e5"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.4"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "b423576adc27097764a90e163157bcfc9acf0f46"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.3.2"
weakdeps = ["ChainRulesCore", "InverseFunctions"]

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "725421ae8e530ec29bcbdddbe91ff8053421d023"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.1"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.SummaryTables]]
deps = ["CategoricalArrays", "DataFrames", "EnumX", "HypothesisTests", "MultipleTesting", "NaturalSort", "OrderedCollections", "Printf", "SHA", "Statistics", "StatsBase", "Tables", "WriteDocx"]
git-tree-sha1 = "04b2e917956ae2083a78033ce6adc0cd843439b6"
uuid = "6ce4ecf0-73a7-4ce3-9fb4-80ebfe887b60"
version = "3.3.0"

[[deps.SymbolicIndexingInterface]]
deps = ["Accessors", "ArrayInterface", "RuntimeGeneratedFunctions", "StaticArraysCore"]
git-tree-sha1 = "d6c04e26aa1c8f7d144e1a8c47f1c73d3013e289"
uuid = "2efcf032-c050-4f8e-a9bb-153293bab1f5"
version = "0.3.38"

[[deps.SymbolicLimits]]
deps = ["SymbolicUtils"]
git-tree-sha1 = "fabf4650afe966a2ba646cabd924c3fd43577fc3"
uuid = "19f23fe9-fdab-4a78-91af-e7b7767979c3"
version = "0.2.2"

[[deps.SymbolicUtils]]
deps = ["AbstractTrees", "ArrayInterface", "Bijections", "ChainRulesCore", "Combinatorics", "ConstructionBase", "DataStructures", "DocStringExtensions", "DynamicPolynomials", "ExproniconLite", "LinearAlgebra", "MultivariatePolynomials", "NaNMath", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArrays", "SymbolicIndexingInterface", "TaskLocalValues", "TermInterface", "TimerOutputs", "Unityper", "WeakValueDicts"]
git-tree-sha1 = "e2ddc57092cced7b05cb7bf848ab81181462ec5c"
uuid = "d1185830-fcd6-423d-90d6-eec64667417b"
version = "3.19.0"

    [deps.SymbolicUtils.extensions]
    SymbolicUtilsLabelledArraysExt = "LabelledArrays"
    SymbolicUtilsReverseDiffExt = "ReverseDiff"

    [deps.SymbolicUtils.weakdeps]
    LabelledArrays = "2ee39098-c373-598a-b85f-a56591580800"
    ReverseDiff = "37e2e3b7-166d-5795-8a7a-e32c996b4267"

[[deps.Symbolics]]
deps = ["ADTypes", "ArrayInterface", "Bijections", "CommonWorldInvalidations", "ConstructionBase", "DataStructures", "DiffRules", "Distributions", "DocStringExtensions", "DomainSets", "DynamicPolynomials", "LaTeXStrings", "Latexify", "Libdl", "LinearAlgebra", "LogExpFunctions", "MacroTools", "Markdown", "NaNMath", "OffsetArrays", "PrecompileTools", "Primes", "RecipesBase", "Reexport", "RuntimeGeneratedFunctions", "SciMLBase", "Setfield", "SparseArrays", "SpecialFunctions", "StaticArraysCore", "SymbolicIndexingInterface", "SymbolicLimits", "SymbolicUtils", "TermInterface"]
git-tree-sha1 = "326982e1f8a8214ff83cc427484acc858f975c74"
uuid = "0c5d862f-8b57-4792-8d23-62f2024744c7"
version = "6.29.2"

    [deps.Symbolics.extensions]
    SymbolicsForwardDiffExt = "ForwardDiff"
    SymbolicsGroebnerExt = "Groebner"
    SymbolicsLuxExt = "Lux"
    SymbolicsNemoExt = "Nemo"
    SymbolicsPreallocationToolsExt = ["PreallocationTools", "ForwardDiff"]
    SymbolicsSymPyExt = "SymPy"

    [deps.Symbolics.weakdeps]
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    Groebner = "0b43b601-686d-58a3-8a1c-6623616c7cd4"
    Lux = "b2108857-7c20-44ae-9111-449ecde12c47"
    Nemo = "2edaba10-b0f1-5616-af89-8c11ac63239a"
    PreallocationTools = "d236fae5-4411-538c-8e31-a6e3d9e00b46"
    SymPy = "24249f21-da20-56a4-8eb1-6a02cf4ae2e6"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "598cd7c1f68d1e205689b1c2fe65a9f85846f297"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.0"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TaskLocalValues]]
git-tree-sha1 = "d155450e6dff2a8bc2fcb81dcb194bd98b0aeb46"
uuid = "ed4db957-447d-4319-bfb6-7fa9ae7ecf34"
version = "0.1.2"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.TermInterface]]
git-tree-sha1 = "d673e0aca9e46a2f63720201f55cc7b3e7169b16"
uuid = "8ea1fca8-c5ef-4a55-8b96-4e9afe9c9a3c"
version = "2.0.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TestHandcalcFunctions]]
git-tree-sha1 = "54dac4d0a0cd2fc20ceb72e0635ee3c74b24b840"
uuid = "6ba57fb7-81df-4b24-8e8e-a3885b6fcae7"
version = "0.2.4"

[[deps.TimerOutputs]]
deps = ["ExprTools", "Printf"]
git-tree-sha1 = "f57facfd1be61c42321765d3551b3df50f7e09f6"
uuid = "a759f4b9-e2f1-59dc-863e-4aeb61b1ea8f"
version = "0.5.28"

    [deps.TimerOutputs.extensions]
    FlameGraphsExt = "FlameGraphs"

    [deps.TimerOutputs.weakdeps]
    FlameGraphs = "08572546-2f56-4bcf-ba4e-bab62c3a3f89"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.URIs]]
git-tree-sha1 = "67db6cc7b3821e19ebe75791a9dd19c9b1188f2b"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.5.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.UnPack]]
git-tree-sha1 = "387c1f73762231e86e0c9c5443ce3b4a0a9a0c2b"
uuid = "3a884ed6-31ef-47d7-9d2a-63182c4928ed"
version = "1.0.2"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Unitful]]
deps = ["Dates", "LinearAlgebra", "Random"]
git-tree-sha1 = "c0667a8e676c53d390a09dc6870b3d8d6650e2bf"
uuid = "1986cc42-f94f-5a68-af5c-568840ba703d"
version = "1.22.0"
weakdeps = ["ConstructionBase", "InverseFunctions"]

    [deps.Unitful.extensions]
    ConstructionBaseUnitfulExt = "ConstructionBase"
    InverseFunctionsUnitfulExt = "InverseFunctions"

[[deps.UnitfulLatexify]]
deps = ["LaTeXStrings", "Latexify", "Unitful"]
git-tree-sha1 = "975c354fcd5f7e1ddcc1f1a23e6e091d99e99bc8"
uuid = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"
version = "1.6.4"

[[deps.Unityper]]
deps = ["ConstructionBase"]
git-tree-sha1 = "25008b734a03736c41e2a7dc314ecb95bd6bbdb0"
uuid = "a7c27f48-0311-42f6-a7f8-2c11e75eb415"
version = "0.1.6"

[[deps.WeakValueDicts]]
git-tree-sha1 = "98528c2610a5479f091d470967a25becfd83edd0"
uuid = "897b6980-f191-5a31-bcb0-bf3c4585e0c1"
version = "0.1.0"

[[deps.WriteDocx]]
deps = ["EnumX", "EzXML", "MacroTools", "OrderedCollections", "ZipFile"]
git-tree-sha1 = "447836a7025e3ac9a6041922d99830bc4b3deb2e"
uuid = "d049ceea-54ee-41d7-a26f-ba29db3b6599"
version = "1.1.0"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.ZipFile]]
deps = ["Libdl", "Printf", "Zlib_jll"]
git-tree-sha1 = "f492b7fe1698e623024e873244f10d89c95c340a"
uuid = "a5390f91-8eb1-5f08-bee0-b1d1ffed6cea"
version = "0.10.1"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"
"""

# ╔═╡ Cell order:
# ╠═b2da04e0-ff6f-11ef-3db4-8165a7ebfc2e
# ╠═80f18465-cc64-4335-bc7b-55df0af9b6c2
# ╠═027cc2b1-c160-46f7-857b-c16ce95ed18c
# ╟─ae310438-a7cb-4de3-8778-fa189a100a1b
# ╟─3d456a96-4138-4f53-a033-aa80cc1c39fa
# ╟─42230b7f-8cd8-418e-af59-596c79a7fa43
# ╟─b57018dc-8049-4653-9e20-698e16cc1552
# ╟─4db40be3-65cf-4a21-836d-7672768db456
# ╟─8d089fd6-82e9-4e23-ae4c-8eeb832734b1
# ╟─4f22d62b-baef-4732-8dd7-5648bad8f5e5
# ╟─b847e1b1-008e-4caa-b8ae-7cb37b5e73a3
# ╟─f547952e-feed-45b1-ad69-25d5b5d289f4
# ╟─fc68a3d0-656d-4efc-9239-11636d2f6500
# ╟─49c6b23d-58f2-49f2-a6f4-ba08a6ad4330
# ╟─a4cbd8fd-8c57-4bc0-a6d7-ba68714716dc
# ╟─c6c9ea3e-1088-4fd7-9225-2ccb6988a45b
# ╟─29f7f3ac-5aa4-4613-875e-cc5b3064cab4
# ╟─658d2f98-0244-49ca-8d40-8bee762e9288
# ╟─9aa4b5c4-81c5-43b6-b3ec-32faf9c30695
# ╟─22885e67-f717-415c-8c97-e16a3db44c39
# ╟─cf962767-3d1b-4cf8-a9c9-94082b7dafcb
# ╟─084a1034-e187-4ce0-ba7b-289af1a0c181
# ╟─d9208986-cfe8-46b1-bdec-51ae67db529e
# ╟─e5c956a1-7803-4bf9-9663-f39c126e2522
# ╟─2298372c-ffe5-4820-b0c3-1903dbca929a
# ╟─05afdf93-e0f9-43b8-bd1b-4e9951ab6e00
# ╟─8121a598-bbfc-4a60-b7a8-5e04b9f3079b
# ╟─c83108fe-c227-46db-bb15-a33d81ba2407
# ╟─8ef04446-1dbd-480d-b49a-a79ba9e8f015
# ╟─df98734f-adda-44e1-b9d9-7656c1a0dc62
# ╟─ed5643bf-9147-4af3-828e-8b976af35624
# ╟─78784a0f-343f-468d-a319-67dd0739acf7
# ╟─6c4aec09-d71f-4328-bb32-fc5408809086
# ╟─fd5d62c7-491e-4a3e-ad50-f31e5e1f81fd
# ╟─48f8a053-29bb-422f-b203-c51b6ba1eab9
# ╟─5f3ef1ab-3280-41fb-a6b4-53212a664630
# ╟─66d2c12a-2885-4c03-8da5-3d7ad6dee360
# ╟─1c9c182a-0627-4d75-802f-2677cc26fbdb
# ╟─9ee27fcb-f472-45da-95f1-7defe75b6b50
# ╟─5df76aa2-aacc-4ffa-8a72-4bba26e690a4
# ╟─ccb73a9f-1bc1-4293-ac4f-161106411c94
# ╟─87c0ceda-75d3-492b-a071-d2813f892c13
# ╟─28d3fe04-6513-4647-8eff-a7b6bb3833bf
# ╠═5f702941-0371-4148-827b-8922999a9ee3
# ╟─1f16805b-edf3-47f1-8bdb-b10fd6344131
# ╟─732337cf-141d-4694-a839-b6dbf33149ba
# ╟─47f6d488-5c99-4635-b3de-0db1c0bd25f8
# ╟─8e38639f-5913-49d7-9f86-7b2e9abd49b8
# ╟─96414313-cc3d-4e79-b067-534b9ef440f6
# ╟─f8e3eb62-ac3a-4645-b341-a9e63c3d8abd
# ╟─0ff27e34-bc15-49ef-a5fe-a71fffd4acb2
# ╟─baecef75-a95f-479b-a45e-fae2a7c7df09
# ╟─9345cc82-e951-4eea-91bc-3cf6bd503327
# ╟─ff7d932b-44c4-48d0-a06c-8f50ac0718fe
# ╟─88cd1122-e048-4606-a1aa-01abf53e3166
# ╟─a9f6ddf2-6114-4ede-8696-35a39adda062
# ╟─c2a51979-4a0c-45dd-a9d7-2af90e80f012
# ╟─9285bc03-1746-4c5f-8411-d859273fbc06
# ╟─20a657f5-2cdc-46b6-8919-389f7ee812b0
# ╟─30d2fd1a-8025-4e4e-aee4-d712252a2cec
# ╟─ba66fcf3-34a0-4d6e-9421-852ac6eb8a79
# ╟─00d22203-2ccd-408a-b791-c5a12abb53bf
# ╟─bc23969d-aaf6-4f06-ad48-0f628c86cb6f
# ╠═1be46ba1-ddc7-4657-b264-6a170968a0fd
# ╟─e720a006-63cc-4467-aee7-eb4ac1a72d4b
# ╟─8f4babd3-d679-4d9c-8ca8-cc852b10a04b
# ╟─a7d143b7-c216-478e-ae83-e4ef6125ab08
# ╟─699bae72-e69c-4111-b4d2-eabc635bd75f
# ╟─3d194c62-1450-47a5-89e6-bc3ba42684c9
# ╟─ab0e9d55-595f-4f61-9ceb-b9084f8d3fa0
# ╟─797936ac-8696-4f40-9b39-1d380d698edd
# ╟─cf93d9d1-7373-401d-9ca7-962b48fb96a9
# ╟─fdda1c3c-3721-4f9e-b032-5ecd4baf9928
# ╟─9cfb37cf-2e90-4ddc-87f2-3adfff4ffe07
# ╟─38110d01-a1cf-4142-bad6-b1f54c2707d4
# ╟─4b179948-2742-4b59-9507-62ba7f76e28d
# ╟─b6bb7fdd-aecd-41a0-934a-2981155355d5
# ╟─3d5a0e0f-e596-4112-8b29-29a965bf7e79
# ╠═9d35446e-b838-493d-a70c-b0d526050b40
# ╟─1934ea7f-da27-457d-90d9-539643a4f410
# ╟─7ad9475c-c627-46c6-9a3c-dee1948813df
# ╠═4ee6a7f9-7b46-4315-91d9-045ae6cb6ae6
# ╠═94a1af2f-8d24-45b0-8698-953d274b7dee
# ╠═f05e9c74-217d-4e9b-9c81-dbc532955c32
# ╠═2e218d89-a015-42a7-b294-6eefc8645b8a
# ╠═2d8481ab-752a-49c2-91c6-8066509e4f83
# ╟─6221e2b7-bd96-4319-b484-71841d655e40
# ╟─b2dc96b9-6bcd-444a-9529-b238264a45d1
# ╠═23bef496-953f-4c5f-89c8-1ac5cdea05be
# ╟─db44a838-7818-4798-a9be-1c1b9f9d9868
# ╟─acaefb97-3439-4a62-86ed-daf76988fa04
# ╠═6c215c39-ecb1-4ece-af5b-6614311ae7e1
# ╟─fb20596d-ac09-4ff5-bc0c-2833e61ccc37
# ╟─7ad6e59b-cb77-4c90-8f9c-c43f227095f5
# ╠═29ac282c-0429-47a0-9da2-b7a0449b4e4a
# ╠═f1d07d6d-a126-4f41-a246-758e0861aed3
# ╠═a9a8cd53-ed30-4d21-af3c-dfb6e2f46440
# ╟─031d5747-990b-4ca6-b817-2154b27dce5b
# ╠═b8f2e603-d164-4d40-9ba5-621c8f2c9308
# ╟─5fef5947-3676-44a7-9cbb-53146c7e14e8
# ╠═fc849125-4303-4b13-a0a6-61e1c5bcae84
# ╠═fdb85668-cc2e-4489-a01e-ed778ca1fb6a
# ╠═26c6c526-64fa-4aa4-a79f-a2bcf47c8d88
# ╟─3c5fd804-404d-46d6-82b3-e867bbb34aa3
# ╟─d350a9a1-44c7-4001-966e-9317cfced115
# ╟─156eb9b3-b31c-4795-90d5-c00795489e87
# ╟─c433d46d-71a6-4e4e-b3e8-8bf3ed17630d
# ╟─3e90eab6-78fb-4b81-b9e7-0dbe633edb57
# ╟─b93b00c9-4369-4e43-b38b-2c22aa96e352
# ╟─9cc812a2-0765-48ff-91df-e1aebace845e
# ╟─5b68de08-9fbb-4b43-8d86-5cc865de814d
# ╠═39ae2e59-0496-4e90-b12f-bb7ad90dc229
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
