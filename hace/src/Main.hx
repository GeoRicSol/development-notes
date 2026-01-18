import js.Browser;
import js.html.Element;

typedef Person = {
    var name:String;
    var age:Int;
    var city:String;
    var score:Int;
}

class Main {
    static var data:Array<Person>;
    static var filtered:Array<Person>;
    static var currentSortColumn:String = "";
    static var sortAscending:Bool = true;

    static function main() {
        var jsonString = haxe.Resource.getString("data.json");
        data = haxe.Json.parse(jsonString);
        filtered = data.copy();

        injectCSS();
        buildFilterPanel();
        buildTable();
    }

    // -------------------------------------------------------------
    // 1. CSS Styling
    // -------------------------------------------------------------
    static function injectCSS() {
        var css = "
            table {
                border-collapse: collapse;
                margin: 20px;
                font-family: Arial, sans-serif;
                width: 600px;
            }
            th, td {
                padding: 10px;
                border: 1px solid #ccc;
                text-align: left;
            }
            th {
                background: #444;
                color: white;
                cursor: pointer;
                user-select: none;
            }
            tr:nth-child(even) {
                background: #f2f2f2;
            }
            tr:hover {
                background: #e0e0e0;
            }
            #searchBox {
                margin: 20px;
                padding: 8px;
                width: 300px;
                font-size: 16px;
            }
            .sort-icon {
                margin-left: 6px;
                font-size: 12px;
                opacity: 0.7;
            }
        ";

        var style = Browser.document.createElement("style");
        style.textContent = css;
        Browser.document.head.appendChild(style);
    }

    // -------------------------------------------------------------
    // 2. Search box for filtering
    // -------------------------------------------------------------
static function buildFilterPanel() {
    var doc = Browser.document;

    var container = doc.createElement("div");
    container.id = "filterPanel";
    container.style.margin = "20px";
    container.style.display = "flex";
    container.style.flexWrap = "wrap";
    container.style.gap = "10px";

    // --- Name filter ---
    var nameInput:js.html.InputElement =
        cast doc.createElement("input");
    nameInput.placeholder = "Filter by name";
    nameInput.oninput = function(_) applyFilters();
    nameInput.id = "filterName";
    container.appendChild(nameInput);

    // --- City filter ---
    var cityInput:js.html.InputElement =
        cast doc.createElement("input");
    cityInput.placeholder = "Filter by city";
    cityInput.oninput = function(_) applyFilters();
    cityInput.id = "filterCity";
    container.appendChild(cityInput);

    // --- Age min ---
    var ageMin:js.html.InputElement =
        cast doc.createElement("input");
    ageMin.placeholder = "Min age";
    ageMin.type = "number";
    ageMin.oninput = function(_) applyFilters();
    ageMin.id = "filterAgeMin";
    container.appendChild(ageMin);

    // --- Age max ---
    var ageMax:js.html.InputElement =
        cast doc.createElement("input");
    ageMax.placeholder = "Max age";
    ageMax.type = "number";
    ageMax.oninput = function(_) applyFilters();
    ageMax.id = "filterAgeMax";
    container.appendChild(ageMax);

    // --- Score min ---
    var scoreMin:js.html.InputElement =
        cast doc.createElement("input");
    scoreMin.placeholder = "Min score";
    scoreMin.type = "number";
    scoreMin.oninput = function(_) applyFilters();
    scoreMin.id = "filterScoreMin";
    container.appendChild(scoreMin);

    doc.body.appendChild(container);
}

static function applyFilters() {
    var doc = Browser.document;

    var name = (cast doc.getElementById("filterName"):js.html.InputElement).value.toLowerCase();
    var city = (cast doc.getElementById("filterCity"):js.html.InputElement).value.toLowerCase();

    var ageMinStr = (cast doc.getElementById("filterAgeMin"):js.html.InputElement).value;
    var ageMaxStr = (cast doc.getElementById("filterAgeMax"):js.html.InputElement).value;
    var scoreMinStr = (cast doc.getElementById("filterScoreMin"):js.html.InputElement).value;

    var ageMin = ageMinStr == "" ? null : Std.parseInt(ageMinStr);
    var ageMax = ageMaxStr == "" ? null : Std.parseInt(ageMaxStr);
    var scoreMin = scoreMinStr == "" ? null : Std.parseInt(scoreMinStr);

    filtered = data.filter(p -> {
        if (name != "" && p.name.toLowerCase().indexOf(name) == -1) return false;
        if (city != "" && p.city.toLowerCase().indexOf(city) == -1) return false;

        if (ageMin != null && p.age < ageMin) return false;
        if (ageMax != null && p.age > ageMax) return false;

        if (scoreMin != null && p.score < scoreMin) return false;

        return true;
    });

    buildTable();
}

    // -------------------------------------------------------------
    // 3. Build the table (called after filtering or sorting)
    // -------------------------------------------------------------
    static function buildTable() {
        var doc = Browser.document;

        // Remove old table
        var old = doc.getElementById("peopleTable");
        if (old != null) old.remove();

        var table = doc.createElement("table");
        table.id = "peopleTable";

        // Header row
        var header = doc.createElement("tr");
        addHeader(header, "Name",  "name");
        addHeader(header, "Age",   "age");
        addHeader(header, "City",  "city");
        addHeader(header, "Score", "score");
        table.appendChild(header);

        // Data rows
        for (person in filtered) {
            var row = doc.createElement("tr");

            row.appendChild(cell(person.name));
            row.appendChild(cell(Std.string(person.age)));
            row.appendChild(cell(person.city));
            row.appendChild(cell(Std.string(person.score)));

            table.appendChild(row);
        }

        doc.body.appendChild(table);
    }

    // -------------------------------------------------------------
    // 4. Helper: create a table cell
    // -------------------------------------------------------------
    static function cell(text:String):Element {
        var td = Browser.document.createElement("td");
        td.textContent = text;
        return td;
    }

    // -------------------------------------------------------------
    // 5. Sortable header with icons
    // -------------------------------------------------------------
    static function addHeader(row:Element, title:String, field:String) {
        var th = Browser.document.createElement("th");

        var label = Browser.document.createElement("span");
        label.textContent = title;

        var icon = Browser.document.createElement("span");
        icon.className = "sort-icon";

        // Show icon only on active column
        if (currentSortColumn == field) {
            icon.textContent = sortAscending ? "▲" : "▼";
        }

        th.appendChild(label);
        th.appendChild(icon);

        th.onclick = function(_) {
            if (currentSortColumn == field) {
                sortAscending = !sortAscending;
            } else {
                currentSortColumn = field;
                sortAscending = true;
            }

            filtered.sort(function(a, b) {
                var va = Reflect.field(a, field);
                var vb = Reflect.field(b, field);

                if (va < vb) return sortAscending ? -1 : 1;
                if (va > vb) return sortAscending ? 1 : -1;
                return 0;
            });

            buildTable();
        };

        row.appendChild(th);
    }
}