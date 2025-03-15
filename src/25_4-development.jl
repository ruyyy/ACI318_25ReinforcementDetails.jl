### A Pluto.jl notebook ###
# v0.20.3

using Markdown
using InteractiveUtils

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
end

# ╔═╡ 80f18465-cc64-4335-bc7b-55df0af9b6c2
@fromparent import *

# ╔═╡ 027cc2b1-c160-46f7-857b-c16ce95ed18c
names(ACI318_25ReinforcementDetails; all=true)

# ╔═╡ e720a006-63cc-4467-aee7-eb4ac1a72d4b
epoxy_list = [
	"Epoxy-coated or zinc and epoxy dual-coated reinforcement with clear cover less than 3d_b or clear spacing less than 6d_b";
	"Epoxy-coated or zinc and epoxy dual-coated reinforcement for all other conditions";
	"Uncoated or zinc-coated (galvanized) reinforcement";
]

# ╔═╡ a7d143b7-c216-478e-ae83-e4ef6125ab08
casting_position_list = [
	"More than 12 in. of fresh concrete placed below horizontal reinforcement";
	"Other";
]

# ╔═╡ 40bc31bb-19f0-41f0-845d-04ec41f3bb32
function ℓ_d(
	rebar_size, 
	f_c_used, 
	case,
	reinforcement_grade, 
	lightweight_concrete, 
	epoxy_type, 
	casting_position, 
)
	d_b = rebar_size * 1/8 * 1.0u"inch"

	# Yielding strength of reinforcement
	f_y = if reinforcement_grade == 40
		40_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 60
		60_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 80
		80_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 100
		100_000.0u"lbf / inch^2"
	end # if

	# Lightweight factor
	λ = if lightweight_concrete == true
		0.75
	elseif lightweight_concrete == false
		1.00
	end # if

	# Reinforcement grade factor
	Ψ_g = if reinforcement_grade == 40 || reinforcement_grade == 60
		1.0
	elseif reinforcement_grade == 80
		1.15
	elseif reinforcement_grade == 100
		1.3
	end # if

	# Epoxy factor
	Ψ_e = if epoxy_type == epoxy_list[1]
		1.5
	elseif epoxy_type == epoxy_list[2]
		1.2
	elseif epoxy_type == epoxy_list[3]
		1.0
	end # if

	# Rebar size factor
	Ψ_s = if rebar_size ≥ 7
		1.0
	elseif rebar_size ≤ 6
		0.8
	end # if

	# Casting position factor
	Ψ_t = if casting_position == casting_position_list[1]
		1.3
	elseif casting_position == casting_position_list[2]
		1.0
	end # if

	# Maximum concrete strength
	f_c_max = (100.0u"lbf^0.5 / inch")^2
	f_c = min(f_c_max, f_c_used)

	ΨtΨe = min(1.7, Ψ_t * Ψ_e)
	
	# Develpment length
	ℓ_d = max(
		12.0u"inch",
		
		if case == 1
			(3/40) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (ΨtΨe * Ψ_s * Ψ_g / (1.5)) * d_b # c_b + K_tr / d_b
		elseif case == 2
			(3/40) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (ΨtΨe * Ψ_s * Ψ_g / (1.0)) * d_b # c_b + K_tr / d_b
		end # if
	)

	return ℓ_d
end # ℓ_d

# ╔═╡ 797936ac-8696-4f40-9b39-1d380d698edd
confining_reinforcement_list = [
	"For No. 11 and smaller bars with A_th ≥ 0.4 A_hs or s ≥ 6 d_b";
	"Other";
]

# ╔═╡ 3d194c62-1450-47a5-89e6-bc3ba42684c9
location_list = [
	"For No. 11 and smaller diameter hooked bars: (1) Terminating inside column core with side cover normal to plane of hook ≥ 2.5 in., or (2) With side cover normal to plane of hook ≥ 6d_b"; 
	"Other";
]

# ╔═╡ 6d0fd8f1-d97d-4555-980a-7deec7aefbe4
function ℓ_dh(
	rebar_size, 
	f_c_used, 
	reinforcement_grade, 
	lightweight_concrete, 
	epoxy_type, 
	confining_reinforcement, 
	location,
)
# let#begin
	d_b = rebar_size * 1/8 * 1.0u"inch"
	
# @handcalcs begin

	# Yielding strength of reinforcement
	f_y = if reinforcement_grade == 40
		40_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 60
		60_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 80
		80_000.0u"lbf / inch^2"
	elseif reinforcement_grade == 100
		100_000.0u"lbf / inch^2"
	end # if

	# Lightweight factor
	λ = if lightweight_concrete == true
		0.75
	elseif lightweight_concrete == false
		1.00
	end # if

	# Epoxy factor
	Ψ_e = if epoxy_type == epoxy_list[1] || epoxy_type == epoxy_list[2]
		1.2
	elseif epoxy_type == epoxy_list[3]
		1.0
	end # if

	# Confining reinforcement
	Ψ_r = if confining_reinforcement == confining_reinforcement_list[1]
		1.0
	elseif confining_reinforcement == confining_reinforcement_list[2]
		1.6
	end # if

	# Location
	Ψ_o = if location == location_list[1]
		1.0
	elseif location == location_list[2]
		1.25
	end # if

	Ψ_c = if f_c_used < 6000.0u"psi"
		f_c_used/15_000.0u"psi" + 0.6
	elseif f_c_used ≥ 6000.0u"psi"
		1.0
	end # if
	
	# Maximum concrete strength
	f_c_max = (100.0u"lbf^0.5 / inch")^2
	f_c = min(f_c_max, f_c_used)

	
	# Develpment length
	ℓ_dh = max(
		6.0u"inch",
		8 * d_b,
		(1/55) * (f_y / (λ * √(f_c) * 1.0u"lbf^0.5 / inch")) * (Ψ_e * Ψ_r * Ψ_o * Ψ_c) * (d_b^(1.5) / 1.0u"inch^0.5")
	)

	return ℓ_dh
# end precision=2 len=:long
end # ℓ_d

# ╔═╡ 112e77de-a9c4-467e-9278-c16b788127b7
begin
	f_c_used = 8000.0u"lbf/inch^2"
	lightweight_concrete = false
	reinforcement_grade = 60
	epoxy_type = epoxy_list[3]
	rebar_size = 7
	casting_position = casting_position_list[1]
	case = 1
	confining_reinforcement = confining_reinforcement_list[1]
	location = location_list[1]
end

# ╔═╡ 23bb5739-092a-408e-95bd-14cffa8e3cda
preferred_length = u"inch"
# preferred_length = u"cm"
# preferred_length = u"mm"

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

# ╔═╡ 7c54ec65-8575-4a42-9188-d83966d94523
begin
	ℓ_d_table_top_inch = ℓ_d.(
		rebar_list, 
		f_c_used, 
		case,
		reinforcement_grade, 
		lightweight_concrete, 
		epoxy_type, 
		casting_position_list[1], 
	)
	
	ℓ_d_table_bot_inch = ℓ_d.(
		rebar_list, 
		f_c_used, 
		case,
		reinforcement_grade, 
		lightweight_concrete, 
		epoxy_type, 
		casting_position_list[2], 
	)
	ℓ_d_table_hook_inch = ℓ_dh.(
		rebar_list, 
		f_c_used, 
		reinforcement_grade, 
		lightweight_concrete, 
		epoxy_type, 
		confining_reinforcement, 
		location,
	)
end

# ╔═╡ 78784a0f-343f-468d-a319-67dd0739acf7
begin
	ℓ_d_table_top = ℓ_d_table_top_inch#ceil.(preferred_length, ℓ_d_table_top_inch)
	ℓ_d_table_bot = ceil.(preferred_length, ℓ_d_table_bot_inch)
	ℓ_d_table_hook = ceil.(preferred_length, ℓ_d_table_hook_inch)
end

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

# ╔═╡ 8b3eeb4a-8f59-4ef8-ae83-08fc36c6331f
begin
	header_1 = ["", "", "Tension", "Tension", "Tension"]
	header_2 = ["Bar Size", "Bar Size", "Development", "Development", "Development"]
	header_3 = ["", "", "Top", "Bot", "with Hook"]
	header_4 = ["1/8 in.", u"mm", preferred_length, preferred_length, preferred_length]
	
	data = hcat(
		"#" .* string.(rebar_list), 
		"#" .* string.(rebar_list_SI),  
		ℓ_d_table_top  ./ preferred_length, 
		ℓ_d_table_bot  ./ preferred_length,
		ℓ_d_table_hook ./ preferred_length,
	)
	
	labels = ["" for i=1:size(data)[1]+4]
		
	body = [
	    Cell.(
			header_1, 
			bold = true, 
			# italic = true,
			# underline = true,
			# halign = :center, # :left :center :right
			# valign = :center, # :top :center :bottom
			# indent_pt = 50,
			# border_bottom = false,
			merge = true, # All adjacent cells that are == equal to each other and have merge = true will be rendered as one merged cell. 
		)';
	    Cell.(header_2, bold = true, merge = true, border_bottom = false)';
	    Cell.(header_3)';
	    Cell.(header_4, italic = true)';
	    Cell.(data)
	]

	Table(
		header = 4,
		# footer = 16,
		# footnotes = ["Footnote 1:", "Footnote 2:"],
		# linebreak_footnotes = false,
		rowgaps = [7 => 5.0, 10 => 5.0, 13 => 5.0],
		colgaps = [3 => 10.0, ],
		hcat(
		    Cell.(labels, italic = true, halign = :right),
		    body
		),
	    round_digits = 0,
    	round_mode = :digits,
		trailing_zeros = true,
	)
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

# ╔═╡ 193e4d46-2155-4c9f-beb0-3b4edd10cc80
Markdown.parse("""
#### 25.4.2.3



$(
remove_arguments(
	 @latexrun ℓ_d3() = 1
)
)

##### Arguments 
- ``  ``: .

##### Reference
- ACI 318-19: 25.4.2.3.
""")

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

# ╔═╡ dfba23f5-64e0-4905-8646-8b6c51aecc34


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
UnitfulLatexify = "45397f5d-5981-4c77-b2b3-fc36d6e9b728"

[compat]
Handcalcs = "~0.4.4"
HypertextLiteral = "~0.9.5"
LaTeXStrings = "~1.4.0"
Latexify = "~0.16.5"
PlutoDevMacros = "~0.9.0"
PlutoExtras = "~0.7.14"
PlutoPlotly = "~0.6.2"
PlutoUI = "~0.7.61"
PrettyTables = "~2.4.0"
SummaryTables = "~3.3.0"
UnitfulLatexify = "~1.6.4"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.2"
manifest_format = "2.0"
project_hash = "39e3739f693c2602c5468eb0c7a7f07595abd82e"

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

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

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

[[deps.CodeTracking]]
deps = ["InteractiveUtils", "UUIDs"]
git-tree-sha1 = "7eee164f122511d3e4e1ebadb7956939ea7e1c77"
uuid = "da1fd8a2-8d9e-5ec2-8556-3022fb5608a2"
version = "1.3.6"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "26ec26c98ae1453c692efded2b17e15125a5bea1"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.28.0"

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

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

    [deps.ConstructionBase.weakdeps]
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

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
git-tree-sha1 = "1d0a14036acb104d9e89698bd408f63ab58cdc82"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.20"

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

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EnumX]]
git-tree-sha1 = "bdb1942cd4c45e3c678fd11569d5cccd80976237"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.4"

[[deps.EzXML]]
deps = ["Printf", "XML2_jll"]
git-tree-sha1 = "380053d61bb9064d6aa4a9777413b40429c79901"
uuid = "8f5d6c58-4d21-5cfd-889c-e3ad7ee6a615"
version = "1.2.0"

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

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

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
git-tree-sha1 = "2bd56245074fab4015b9174f24ceba8293209053"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.27"

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

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

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
git-tree-sha1 = "ce5f5621cac23a86011836badfedf664a612cee4"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.16.5"

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

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.MultipleTesting]]
deps = ["Distributions", "SpecialFunctions", "StatsBase"]
git-tree-sha1 = "1e98f8f732e7035c4333135b75605b74f3462b9b"
uuid = "f8716d33-7c4a-5097-896f-ce0ecbd3ef6b"
version = "0.6.0"

[[deps.NaturalSort]]
git-tree-sha1 = "eda490d06b9f7c00752ee81cfa451efe55521e21"
uuid = "c020b1a1-e9b0-503a-9c33-f039bfc54a85"
version = "1.0.0"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.1+2"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "12f1439c4f986bb868acda6ea33ebc78e19b95ad"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.7.0"

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
deps = ["ColorSchemes", "Dates", "DelimitedFiles", "DocStringExtensions", "JSON", "LaTeXStrings", "Logging", "Parameters", "Pkg", "REPL", "Requires", "Statistics", "UUIDs"]
git-tree-sha1 = "56baf69781fc5e61607c3e46227ab17f7040ffa2"
uuid = "a03496cd-edff-5a9b-9e67-9cda94a718b5"
version = "0.8.19"

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

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "838a3a4188e2ded87a4f9f184b4b0d78a1e91cb7"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.0"

[[deps.Revise]]
deps = ["CodeTracking", "Distributed", "FileWatching", "JuliaInterpreter", "LibGit2", "LoweredCodeUtils", "OrderedCollections", "REPL", "Requires", "UUIDs", "Unicode"]
git-tree-sha1 = "c4171a96893f861e4872b9868f5a7b19da8e9bc8"
uuid = "295af30f-e4ad-537b-8983-00126c2a3abe"
version = "3.6.6"

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

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

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

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

    [deps.SpecialFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"

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

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "a6b1675a536c5ad1a60e5a5153e1fee12eb146e3"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.0"

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

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TestHandcalcFunctions]]
git-tree-sha1 = "54dac4d0a0cd2fc20ceb72e0635ee3c74b24b840"
uuid = "6ba57fb7-81df-4b24-8e8e-a3885b6fcae7"
version = "0.2.4"

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
# ╠═193e4d46-2155-4c9f-beb0-3b4edd10cc80
# ╠═6d0fd8f1-d97d-4555-980a-7deec7aefbe4
# ╟─40bc31bb-19f0-41f0-845d-04ec41f3bb32
# ╠═112e77de-a9c4-467e-9278-c16b788127b7
# ╠═e720a006-63cc-4467-aee7-eb4ac1a72d4b
# ╠═a7d143b7-c216-478e-ae83-e4ef6125ab08
# ╠═797936ac-8696-4f40-9b39-1d380d698edd
# ╠═3d194c62-1450-47a5-89e6-bc3ba42684c9
# ╠═7c54ec65-8575-4a42-9188-d83966d94523
# ╠═78784a0f-343f-468d-a319-67dd0739acf7
# ╠═23bb5739-092a-408e-95bd-14cffa8e3cda
# ╠═8b3eeb4a-8f59-4ef8-ae83-08fc36c6331f
# ╟─00d22203-2ccd-408a-b791-c5a12abb53bf
# ╟─bc23969d-aaf6-4f06-ad48-0f628c86cb6f
# ╟─b6bb7fdd-aecd-41a0-934a-2981155355d5
# ╟─3d5a0e0f-e596-4112-8b29-29a965bf7e79
# ╠═9d35446e-b838-493d-a70c-b0d526050b40
# ╟─6221e2b7-bd96-4319-b484-71841d655e40
# ╟─b2dc96b9-6bcd-444a-9529-b238264a45d1
# ╠═23bef496-953f-4c5f-89c8-1ac5cdea05be
# ╟─db44a838-7818-4798-a9be-1c1b9f9d9868
# ╟─acaefb97-3439-4a62-86ed-daf76988fa04
# ╠═6c215c39-ecb1-4ece-af5b-6614311ae7e1
# ╟─fb20596d-ac09-4ff5-bc0c-2833e61ccc37
# ╠═a9a8cd53-ed30-4d21-af3c-dfb6e2f46440
# ╟─031d5747-990b-4ca6-b817-2154b27dce5b
# ╠═b8f2e603-d164-4d40-9ba5-621c8f2c9308
# ╠═dfba23f5-64e0-4905-8646-8b6c51aecc34
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
