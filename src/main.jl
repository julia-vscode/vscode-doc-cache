using Publish
using Pkg
using Tar
using CodecZlib

packages = [:Publish => "https://github.com/MichaelHatherly/Publish.jl"]

globals = Dict("publish" => Dict("theme" => "Publish.Themes.vscode"));

store_path = joinpath(@__DIR__, "..", "store", "v1")

for (package, url) in packages
    mktempdir() do path
        cd(path) do
            run(`git clone $url package`)

            deploy(joinpath(path, "package", "Project.toml"), joinpath(path, "output"), Publish.markdown; globals);

            # TODO Remove hack

            for file in readdir(joinpath(path, "output", "0.8.0"))
                mv(joinpath(path, "output", "0.8.0", file), joinpath(path, "output", file))
            end
            rm(joinpath(path, "output", "0.8.0"))

            folder_path_for_tarball = joinpath(store_path, "f065f642-d108-4f50-8aa5-6749150a895a")
            mkpath(folder_path_for_tarball)
            tarball_path = joinpath(folder_path_for_tarball, "3db6e66bbb2c81ace04c1454f08331393cb6e508.tar.gz")
            tar_gz = open(tarball_path, write=true)
            tar = GzipCompressorStream(tar_gz)
            Tar.create(joinpath(path, "output"), tar)
            close(tar)
        end
    end
end

