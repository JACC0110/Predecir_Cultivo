async function enviar() {
    const data = {
        temperature: parseFloat(document.getElementById("temp").value),
        ph: parseFloat(document.getElementById("ph").value),
        rainfall: parseFloat(document.getElementById("rain").value)
    };

    const resp = await fetch("/predict", {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify(data)
    });

    if (!resp.ok) {
        document.getElementById("resultado").innerHTML =
            "<p style='color:red;'>Error: No se pudo obtener la predicción.</p>";
        return;
    }

    const json = await resp.json();

    document.getElementById("resultado").innerHTML = `
        <div class="card cultivo-card">
            <h3>🌾 Cultivo recomendado: <b>${json.cultivo}</b></h3>
        </div>

        <div class="card rendimiento-card">
            <h3>📊 Rendimiento esperado: <b>${json.rendimiento} ton/ha</b></h3>
        </div>
    `;
}

document.getElementById("btnPredict").addEventListener("click", enviar);
