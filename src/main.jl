using Publish
using Pkg
using Tar
using CodecZlib

function foo()

packages = [:Publish => "https://github.com/MichaelHatherly/Publish.jl"]

globals = Dict("publish" => Dict("theme" => "Publish.Themes.vscode"));

store_path = joinpath(@__DIR__, "..", "store", "v1")

for (package, url) in packages
    mktempdir() do path
        cd(path) do
            run(`git clone $url package`)

            deploy(joinpath(path, "package", "Project.toml"), joinpath(path, "output"), Publish.markdown; globals, versioned = false)

            # TODO Remove hack
            folder_path_for_tarball = joinpath(store_path, "f065f642-d108-4f50-8aa5-6749150a895a")
            mkpath(folder_path_for_tarball)
            tarball_path = joinpath(folder_path_for_tarball, "b302581743a08b5a542bba0beac0300360b51742.tar.gz")
            open(tarball_path, write=true) do tar_gz
                tar = GzipCompressorStream(tar_gz)
                try
                    Tar.create(joinpath(path, "output"), tar)
                finally
                    close(tar)
                end
            end
        end
    end
end

end

foo()
